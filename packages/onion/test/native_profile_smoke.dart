// Explicit native smoke test; build Rust before running this file.
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';

void main() {
  test(
    'validated startup profiles cross FFI without starting transport',
    () async {
      await OnionCore.init(
        externalLibrary: ExternalLibrary.open(
          Platform.environment['ONION_NATIVE_LIBRARY'] ??
              'rust/target/debug/deps/libonion.so',
        ),
      );
      try {
        final identity = torBuildInfo();
        expect(identity.wrapperVersion, '0.2.0');
        expect(identity.artiClientVersion, '0.47.0');
        expect(identity.target, isNotEmpty);
        expect(identity.rustcVersion, startsWith('rustc '));
        expect(
          identity.artiRequestedFeatures,
          contains('onion-service-client'),
        );
        final profile = SnowflakeBridgeProfile.bundled();
        try {
          expect(profile.bridgeCount(), 2);
          final directory = Directory.systemTemp.createTempSync(
            'onion-startup-',
          );
          try {
            for (final port in <int?>[null, 12345]) {
              final service = await TorService.startConfigured(
                stateDir: '${directory.path}/state-${port ?? 0}',
                cacheDir: '${directory.path}/cache-${port ?? 0}',
                socksPort: 0,
                policy: SocksPolicy.onionOnly,
                settings: TorStartupSettings(
                  connectTimeoutMs: BigInt.from(60000),
                  disablePreemptiveExitCircuits: true,
                ),
                snowflakePort: port,
              );
              try {
                expect(await service.proxyIsAlive(), isTrue);
              } finally {
                await service.stop();
                service.dispose();
              }
            }
            final service =
                await TorService.startConfiguredWithSnowflakeProfile(
                  stateDir: '${directory.path}/profile-state',
                  cacheDir: '${directory.path}/profile-cache',
                  socksPort: 0,
                  policy: SocksPolicy.onionOnly,
                  settings: const TorStartupSettings(
                    disablePreemptiveExitCircuits: true,
                  ),
                  snowflakePort: 12345,
                  profile: profile,
                );
            try {
              expect(await service.proxyIsAlive(), isTrue);
            } finally {
              await service.stop();
              service.dispose();
            }
          } finally {
            directory.deleteSync(recursive: true);
          }

          expect(
            () => SnowflakeBridgeProfile.fromBridgeLines(
              bridgeLines: ['private-invalid-bridge'],
            ),
            throwsA(
              isA<TorFailure>()
                  .having((f) => f.kind, 'kind', TorFailureKind.configuration)
                  .having(
                    (f) => f.logMessage,
                    'message',
                    'Invalid or unsupported Snowflake bridge profile',
                  ),
            ),
          );
          await expectLater(
            TorService.startWithSnowflakeProfile(
              stateDir: '/unused/state',
              cacheDir: '/unused/cache',
              socksPort: 0,
              snowflakePort: 0,
              policy: SocksPolicy.onionOnly,
              profile: profile,
            ),
            throwsA(isA<TorFailure>()),
          );
        } finally {
          profile.dispose();
        }
      } finally {
        OnionCore.dispose();
      }
    },
  );
}
