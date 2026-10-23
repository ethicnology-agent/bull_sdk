// Explicit native smoke test; build Rust, then run:
// fvm flutter test test/native_connection_smoke.dart
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';

void main() {
  test(
    'native FFI preserves per-session diagnostic enums and cursors',
    () async {
      await OnionCore.init(
        externalLibrary: ExternalLibrary.open(
          Platform.environment['ONION_NATIVE_LIBRARY'] ??
              'rust/target/debug/deps/libonion.so',
        ),
      );
      final directory = await Directory.systemTemp.createTemp(
        'onion_connection_ffi_',
      );
      TorService? service;
      TorSession? session;
      try {
        service = await TorService.start(
          stateDir: '${directory.path}/state',
          cacheDir: '${directory.path}/cache',
          socksPort: 0,
          policy: SocksPolicy.any,
        );
        session = await service.openSession(
          socksPort: 0,
          policy: SocksPolicy.onionOnly,
        );
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          await session.socksPort(),
        );
        try {
          socket.add([
            1,
            1,
            0,
          ]); // Invalid SOCKS version, handled without Tor network I/O.
          await socket.flush();
          await socket.drain<void>().timeout(const Duration(seconds: 5));
        } finally {
          socket.destroy();
        }
        final batch = await session.connectionEvents(
          afterSequence: BigInt.zero,
        );
        expect(batch.latestSequence, BigInt.two);
        expect(batch.dropped, BigInt.zero);
        expect(batch.events.map((event) => event.kind), [
          ConnectionEventKind.accepted,
          ConnectionEventKind.failed,
        ]);
        expect(
          batch.events.last.failure,
          ConnectionFailureKind.handshakeFailed,
        );
        expect(batch.events.last.attemptId, BigInt.one);
        expect(batch.events.last.elapsedMs, greaterThanOrEqualTo(BigInt.zero));
        expect(
          (await service.connectionEvents(afterSequence: BigInt.zero)).events,
          isEmpty,
        );
        expect(
          (await session.connectionEvents(
            afterSequence: batch.latestSequence,
          )).events,
          isEmpty,
        );
        await expectLater(
          session.connectionEvents(
            afterSequence: batch.latestSequence + BigInt.one,
          ),
          throwsA(
            isA<TorFailure>().having(
              (failure) => failure.kind,
              'kind',
              TorFailureKind.configuration,
            ),
          ),
        );
        await service.stop();
        expect(
          (await session.connectionEvents(afterSequence: BigInt.zero)).events,
          batch.events,
        );
      } finally {
        await session?.stop();
        await service?.stop();
        session?.dispose();
        service?.dispose();
        await directory.delete(recursive: true);
        OnionCore.dispose();
      }
    },
  );
}
