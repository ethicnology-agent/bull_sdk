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
        final profile = SnowflakeBridgeProfile.bundled();
        try {
          expect(profile.bridgeCount(), 2);
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
