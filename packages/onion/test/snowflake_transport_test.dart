import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.bullbitcoin.onion/snowflake');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Map<String, Object> event(int sequence, {String kind = 'connected'}) => {
    'sequence': sequence,
    'generation': 3,
    'elapsedMs': 125,
    'kind': kind,
    'hasError': false,
  };
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() async {
    await SnowflakeTransport.stop();
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });
  test('rejects unsupported desktop platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(SnowflakeTransport.start, throwsUnsupportedError);
    expect(SnowflakeTransport.readEvents(), throwsUnsupportedError);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test(
      'reads immutable history with loss and cursors on $platform',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'readEvents');
          expect(call.arguments, {'afterSequence': 1});
          return {
            'events': [event(4), event(5, kind: 'future')],
            'latestSequence': 5,
            'dropped': 2,
          };
        });
        final batch = await SnowflakeTransport.readEvents(afterSequence: 1);
        expect(batch.latestSequence, 5);
        expect(batch.dropped, 2);
        expect(batch.events.map((e) => e.kind), [
          SnowflakeEventKind.connected,
          SnowflakeEventKind.unknown,
        ]);
        expect(batch.events.first.generation, 3);
        expect(batch.events.first.elapsedMs, 125);
        expect(batch.events.first.hasError, false);
        expect(() => batch.events.clear(), throwsUnsupportedError);
      },
    );
  }
  test('an empty batch preserves the caller cursor', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {'events': [], 'latestSequence': 8, 'dropped': 0},
    );
    final batch = await SnowflakeTransport.readEvents(afterSequence: 8);
    expect(batch.events, isEmpty);
    expect(batch.latestSequence, 8);
  });
  test('negative cursors are rejected before native invocation', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('must not call native'),
    );
    await expectLater(
      SnowflakeTransport.readEvents(afterSequence: -1),
      throwsArgumentError,
    );
  });
  test(
    'native cursor errors propagate without a silent history reset',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'invalid_event_cursor');
      });
      await expectLater(
        SnowflakeTransport.readEvents(afterSequence: 99),
        throwsA(isA<PlatformException>()),
      );
    },
  );
  test('malformed native batches fail with a fixed diagnostic', () async {
    final invalid = <Object?>[
      null,
      {'events': [], 'latestSequence': 1, 'dropped': 0},
      {'events': [], 'latestSequence': -1, 'dropped': 0},
      {
        'events': [event(2)],
        'latestSequence': 1,
        'dropped': 0,
      },
      {
        'events': [event(1)..['hasError'] = 'private message'],
        'latestSequence': 1,
        'dropped': 0,
      },
      {
        'events': [event(1)..['generation'] = 0],
        'latestSequence': 1,
        'dropped': 0,
      },
      {
        'events': [event(1)..['elapsedMs'] = -1],
        'latestSequence': 1,
        'dropped': 0,
      },
      {
        'events': List.generate(65, (i) => event(i + 1)),
        'latestSequence': 65,
        'dropped': 0,
      },
    ];
    for (final value in invalid) {
      messenger.setMockMethodCallHandler(channel, (_) async => value);
      await expectLater(
        SnowflakeTransport.readEvents(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'Invalid Snowflake event batch',
          ),
        ),
      );
    }
  });
  test('concurrent starts share a lease and stop releases it once', () async {
    var starts = 0;
    var stops = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'start') {
        starts++;
        return 12345;
      }
      if (call.method == 'stop') {
        stops++;
        return null;
      }
      fail('unexpected method');
    });
    expect(
      await Future.wait([
        SnowflakeTransport.start(),
        SnowflakeTransport.start(),
      ]),
      [12345, 12345],
    );
    await SnowflakeTransport.stop();
    await SnowflakeTransport.stop();
    expect(starts, 1);
    expect(stops, 1);
  });
}
