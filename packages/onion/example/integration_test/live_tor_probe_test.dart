import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onion/onion.dart';

// Read-only network experiment: no wallet or recovery material is submitted.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(OnionCore.init);
  for (final snowflake
      in const bool.fromEnvironment('SNOWFLAKE_ONLY')
          ? [true]
          : [false, true]) {
    testWidgets(
      'live Tor circuit ${snowflake ? 'snowflake' : 'direct'}',
      (tester) async {
        final root = await Directory.systemTemp.createTemp('onion_live_');
        TorService? service;
        final clock = Stopwatch()..start();
        final mode = snowflake ? 'snowflake' : 'direct';
        try {
          final snowflakePort = snowflake
              ? await SnowflakeTransport.start()
              : null;
          service = snowflakePort == null
              ? await TorService.startWithConnectTimeout(
                  stateDir: '${root.path}/state',
                  cacheDir: '${root.path}/cache',
                  socksPort: 0,
                  policy: SocksPolicy.onionOnly,
                  connectTimeoutMs: BigInt.from(40000),
                )
              : await TorService.startWithSnowflakeConnectTimeout(
                  stateDir: '${root.path}/state',
                  cacheDir: '${root.path}/cache',
                  socksPort: 0,
                  snowflakePort: snowflakePort,
                  policy: SocksPolicy.onionOnly,
                  connectTimeoutMs: BigInt.from(40000),
                );
          await service.bootstrap().timeout(const Duration(seconds: 180));
          // ignore: avoid_print
          print(
            'LIVE_TOR mode=$mode bootstrap_ms=${clock.elapsedMilliseconds}',
          );
          for (var attempt = 1; attempt <= 2; attempt++) {
            final elapsed = await service
                .probe(
                  host:
                      '5m7enm5y77tdgmaf3d5xuwa5c7fjma7v5ljtwxu4q5jtq6b5utspmpyd.onion',
                  port: 80,
                  timeoutMs: 40000,
                )
                .timeout(const Duration(seconds: 44));
            expect(elapsed, greaterThanOrEqualTo(0));
            // ignore: avoid_print
            print('LIVE_TOR mode=$mode attempt=$attempt circuit_ms=$elapsed');
          }
          if (snowflake) {
            final history = await SnowflakeTransport.readEvents();
            expect(
              history.events.any(
                (event) => event.kind == SnowflakeEventKind.connected,
              ),
              isTrue,
            );
            // ignore: avoid_print
            print(
              'LIVE_TOR mode=$mode events=${history.events.map((event) => event.kind.name).join(',')}',
            );
          }
        } on TorFailure catch (failure) {
          final status = await service?.status();
          // ignore: avoid_print
          print(
            'LIVE_TOR mode=$mode failure=${failure.kind.name} elapsed_ms=${clock.elapsedMilliseconds} fraction=${status?.fraction} ready=${status?.readyForTraffic} blockage=${status?.blockage?.kind.name}',
          );
          rethrow;
        } finally {
          if (snowflake) {
            final events = await SnowflakeTransport.readEvents();
            // ignore: avoid_print
            print(
              'LIVE_TOR mode=$mode native_events=${events.events.map((event) => '${event.kind.name}:${event.elapsedMs}:${event.hasError}').join(',')}',
            );
          }
          await service?.stop();
          service?.dispose();
          if (snowflake) await SnowflakeTransport.stop();
          await root.delete(recursive: true);
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  }
}
