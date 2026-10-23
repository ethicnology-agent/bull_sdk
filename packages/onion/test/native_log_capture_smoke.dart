// Explicit native smoke test, excluded from the default *_test.dart suite.
// Build the Rust library first, then run:
// fvm flutter test test/native_log_capture_smoke.dart
// ONION_NATIVE_LIBRARY can override rust/target/debug/deps/libonion.so.
import 'dart:async';
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';

void main() {
  test(
    'native FFI delivers redacted records and closes pending batch reads',
    () async {
      await OnionCore.init(
        externalLibrary: ExternalLibrary.open(
          Platform.environment['ONION_NATIVE_LIBRARY'] ??
              'rust/target/debug/deps/libonion.so',
        ),
      );
      final directory = await Directory.systemTemp.createTemp('onion_ffi_');
      final logs = OnionLogs.start(filter: 'onion=debug,off');
      final records = <TorLogRecord>[];
      final redactedPeer = Completer<void>();
      final subscription = logs.records.listen((record) {
        records.add(record);
        if (record.message.contains('peer=[redacted]') &&
            !redactedPeer.isCompleted) {
          redactedPeer.complete();
        }
      });
      TorService? service;
      try {
        service = await TorService.start(
          stateDir: '${directory.path}/state',
          cacheDir: '${directory.path}/cache',
          socksPort: 0,
          policy: SocksPolicy.onionOnly,
        );
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          await service.socksPort(),
        );
        try {
          // An invalid SOCKS version fails locally; no bootstrap or network.
          socket.add([0x01, 0x01, 0x00]);
          await socket.flush();
          await redactedPeer.future.timeout(const Duration(seconds: 5));
        } finally {
          socket.destroy();
        }
        expect(
          records.any(
            (record) =>
                record.level == TorLogLevel.info &&
                record.message.contains('isolated socks session bound'),
          ),
          isTrue,
        );
        expect(
          records.every((record) => !record.message.contains('127.0.0.1')),
          isTrue,
        );
        expect(logs.stats.accepted, greaterThanOrEqualTo(BigInt.from(2)));
        expect(logs.stats.dropped, BigInt.zero);

        final replacement = openLogStream(filter: 'onion=warn,off');
        try {
          await subscription.asFuture<void>().timeout(
            const Duration(seconds: 5),
          );
          final pending = replacement.nextBatch();
          replacement.close();
          expect(await pending.timeout(const Duration(seconds: 5)), isEmpty);
          expect(
            () => openLogStream(filter: 'trace'),
            throwsA(isA<TorFailure>()),
          );
        } finally {
          replacement.close();
          replacement.dispose();
        }
      } finally {
        await subscription.cancel();
        logs.close();
        await service?.stop();
        await directory.delete(recursive: true);
        OnionCore.dispose();
      }
    },
  );
}
