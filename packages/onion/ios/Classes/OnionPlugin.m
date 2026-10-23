#import "OnionPlugin.h"
#import <CoreFoundation/CoreFoundation.h>

@import IPtProxy;

static NSString *const OnionSnowflakeChannel = @"com.bullbitcoin.onion/snowflake";
static NSLock *OnionSnowflakeLock;
static IPtProxyController *OnionSnowflakeController;
static NSUInteger OnionSnowflakeLeases;
static NSLock *OnionEventsLock;
static NSMutableArray<NSDictionary *> *OnionEvents;
static int64_t OnionEventSequence;
static int64_t OnionTransportGeneration;

@interface OnionTransportObserver : NSObject <IPtProxyOnTransportEvents>
@property(nonatomic, assign) int64_t generation;
@property(nonatomic, assign) NSTimeInterval startedAt;
- (void)record:(NSString *)kind hasError:(BOOL)hasError;
@end

static OnionTransportObserver *OnionSnowflakeObserver;

@implementation OnionTransportObserver
- (instancetype)init {
  self = [super init];
  if (self) {
    [OnionEventsLock lock];
    _generation = ++OnionTransportGeneration;
    [OnionEventsLock unlock];
    _startedAt = NSProcessInfo.processInfo.systemUptime;
  }
  return self;
}

- (void)record:(NSString *)kind hasError:(BOOL)hasError {
  int64_t elapsedMs = (int64_t)((NSProcessInfo.processInfo.systemUptime - self.startedAt) * 1000);
  [OnionEventsLock lock];
  @try {
    if (OnionEvents.count == 64) [OnionEvents removeObjectAtIndex:0];
    [OnionEvents addObject:@{
      @"sequence": @(++OnionEventSequence), @"generation": @(self.generation),
      @"elapsedMs": @(elapsedMs), @"kind": kind, @"hasError": @(hasError)
    }];
  } @finally {
    [OnionEventsLock unlock];
  }
}

- (void)connected:(NSString *)name {
  if ([name isEqualToString:IPtProxySnowflake]) [self record:@"connected" hasError:NO];
}

- (void)error:(NSString *)name error:(NSError *)error {
  if ([name isEqualToString:IPtProxySnowflake]) [self record:@"discoveryFailed" hasError:error != nil];
}

- (void)stopped:(NSString *)name error:(NSError *)error {
  if ([name isEqualToString:IPtProxySnowflake]) [self record:@"connectionStopped" hasError:error != nil];
}
@end

@interface OnionPlugin ()
@property(nonatomic, assign) BOOL acquired;
@end

@implementation OnionPlugin

+ (void)initialize {
  if (self == [OnionPlugin class]) {
    OnionSnowflakeLock = [[NSLock alloc] init];
    OnionEventsLock = [[NSLock alloc] init];
    OnionEvents = [[NSMutableArray alloc] init];
  }
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:OnionSnowflakeChannel
            binaryMessenger:registrar.messenger];
  OnionPlugin *instance = [[OnionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"start"]) {
    [self start:result];
  } else if ([call.method isEqualToString:@"stop"]) {
    [self releaseLease];
    result(nil);
  } else if ([call.method isEqualToString:@"version"]) {
    result(IPtProxySnowflakeVersion());
  } else if ([call.method isEqualToString:@"readEvents"]) {
    [self readEvents:call.arguments result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)dealloc {
  [self releaseLease];
}

- (void)start:(FlutterResult)result {
  OnionTransportObserver *startingObserver = nil;
  IPtProxyController *candidate = nil;
  [OnionSnowflakeLock lock];
  @try {
    if (self.acquired) {
      long port = [OnionSnowflakeController port:IPtProxySnowflake];
      if ([self validPort:port]) {
        result(@(port));
      } else {
        result([FlutterError errorWithCode:@"snowflake_not_running"
                                   message:@"Snowflake is not running"
                                   details:nil]);
      }
      return;
    }

    if (OnionSnowflakeController == nil) {
      NSURL *support = [[[NSFileManager defaultManager]
          URLsForDirectory:NSApplicationSupportDirectory
                 inDomains:NSUserDomainMask] firstObject];
      NSURL *stateDir = [support URLByAppendingPathComponent:@"onion_pt"
                                                isDirectory:YES];
      NSError *directoryError = nil;
      if (![[NSFileManager defaultManager] createDirectoryAtURL:stateDir
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:&directoryError]) {
        result([FlutterError errorWithCode:@"snowflake_storage"
                                   message:@"Snowflake storage is unavailable"
                                   details:nil]);
        return;
      }

      startingObserver = [[OnionTransportObserver alloc] init];
      [startingObserver record:@"starting" hasError:NO];
      candidate = [[IPtProxyController alloc]
          init:stateDir.path
          enableLogging:NO
          unsafeLogging:NO
          logLevel:@"ERROR"
          transportEvents:startingObserver];
      if (candidate == nil) {
        [startingObserver record:@"startFailed" hasError:YES];
        result([FlutterError errorWithCode:@"snowflake_start_failed"
                                   message:@"Snowflake could not be started"
                                   details:nil]);
        return;
      }

      NSError *startError = nil;
      if (![candidate start:IPtProxySnowflake proxy:@"" error:&startError]) {
        [startingObserver record:@"startFailed" hasError:YES];
        [candidate stop:IPtProxySnowflake];
        result([FlutterError errorWithCode:@"snowflake_start_failed"
                                   message:@"Snowflake could not be started"
                                   details:nil]);
        return;
      }
      long port = [candidate port:IPtProxySnowflake];
      if (![self validPort:port]) {
        [candidate stop:IPtProxySnowflake];
        [startingObserver record:@"startFailed" hasError:YES];
        result([FlutterError errorWithCode:@"snowflake_start_failed"
                                   message:@"Snowflake did not bind a local port"
                                   details:nil]);
        return;
      }
      OnionSnowflakeController = candidate;
      OnionSnowflakeObserver = startingObserver;
      [startingObserver record:@"listening" hasError:NO];
    }

    long port = [OnionSnowflakeController port:IPtProxySnowflake];
    if (![self validPort:port]) {
      result([FlutterError errorWithCode:@"snowflake_not_running"
                                 message:@"Snowflake is not running"
                                 details:nil]);
      return;
    }
    OnionSnowflakeLeases++;
    self.acquired = YES;
    result(@(port));
  } @catch (NSException *exception) {
    if (OnionSnowflakeLeases == 0) {
      [startingObserver record:@"startFailed" hasError:YES];
      @try {
        [candidate stop:IPtProxySnowflake];
      } @catch (__unused NSException *stopException) {
        // The failed controller is discarded even if teardown fails.
      }
      OnionSnowflakeController = nil;
      OnionSnowflakeObserver = nil;
    }
    result([FlutterError errorWithCode:@"snowflake_start_failed"
                               message:@"Snowflake could not be started"
                               details:nil]);
  } @finally {
    [OnionSnowflakeLock unlock];
  }
}

- (void)releaseLease {
  [OnionSnowflakeLock lock];
  @try {
    if (!self.acquired) {
      return;
    }
    self.acquired = NO;
    OnionSnowflakeLeases--;
    if (OnionSnowflakeLeases == 0 && OnionSnowflakeController != nil) {
      [OnionSnowflakeObserver record:@"released" hasError:NO];
      @try {
        [OnionSnowflakeController stop:IPtProxySnowflake];
      } @catch (__unused NSException *exception) {
        // Teardown is best-effort during engine detachment.
      } @finally {
        OnionSnowflakeController = nil;
        OnionSnowflakeObserver = nil;
      }
    }
  } @finally {
    [OnionSnowflakeLock unlock];
  }
}

- (BOOL)validPort:(long)port {
  return port > 0 && port <= UINT16_MAX;
}

- (void)readEvents:(id)arguments result:(FlutterResult)result {
  id after = [arguments isKindOfClass:NSDictionary.class] ? arguments[@"afterSequence"] : nil;
  if (![after isKindOfClass:NSNumber.class] ||
      CFGetTypeID((__bridge CFTypeRef)after) == CFBooleanGetTypeID() ||
      CFNumberIsFloatType((__bridge CFNumberRef)after)) {
    result([FlutterError errorWithCode:@"invalid_event_cursor" message:@"Invalid Snowflake event cursor" details:nil]);
    return;
  }
  int64_t cursor = [after longLongValue];
  NSDictionary *snapshot = nil;
  [OnionEventsLock lock];
  @try {
    if (cursor >= 0 && cursor <= OnionEventSequence) {
      NSMutableArray *batch = [[NSMutableArray alloc] init];
      for (NSDictionary *event in OnionEvents) {
        if ([event[@"sequence"] longLongValue] > cursor) [batch addObject:event];
      }
      int64_t oldest = OnionEventSequence - (int64_t)OnionEvents.count + 1;
      snapshot = @{@"events": batch, @"latestSequence": @(OnionEventSequence), @"dropped": @(MAX(0, oldest - cursor - 1))};
    }
  } @finally {
    [OnionEventsLock unlock];
  }
  if (snapshot == nil) {
    result([FlutterError errorWithCode:@"invalid_event_cursor" message:@"Invalid Snowflake event cursor" details:nil]);
  } else {
    result(snapshot);
  }
}

@end
