import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onion/onion.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(OnionCore.init);

  testWidgets('native logs and session diagnostics cross the Android plugin', (
    tester,
  ) async {
    final root = await Directory.systemTemp.createTemp('onion_diagnostics_');
    final logs = OnionLogs.start(filter: 'onion=debug,off');
    final records = <TorLogRecord>[];
    final handshakeLogged = Completer<void>();
    final subscription = logs.records.listen((record) {
      records.add(record);
      if (record.message.contains('socks connection ended') &&
          !handshakeLogged.isCompleted) {
        handshakeLogged.complete();
      }
    });
    TorService? service;
    TorSession? session;
    try {
      service = await TorService.start(
        stateDir: '${root.path}/state',
        cacheDir: '${root.path}/cache',
        socksPort: 0,
        policy: SocksPolicy.onionOnly,
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
        socket.add([1, 1, 0]);
        await socket.flush();
        await socket.drain<void>().timeout(const Duration(seconds: 5));
      } finally {
        socket.destroy();
      }
      await handshakeLogged.future.timeout(const Duration(seconds: 5));
      final batch = await session.connectionEvents(afterSequence: BigInt.zero);
      expect(batch.events.map((event) => event.kind), [
        ConnectionEventKind.accepted,
        ConnectionEventKind.failed,
      ]);
      expect(batch.events.last.failure, ConnectionFailureKind.handshakeFailed);
      expect(batch.events.last.attemptId, BigInt.one);
      expect(batch.latestSequence, BigInt.two);
      expect(batch.dropped, BigInt.zero);
      expect(
        (await service.connectionEvents(afterSequence: BigInt.zero)).events,
        isEmpty,
      );
      expect(records, isNotEmpty);
      expect(
        records.every((record) => !record.message.contains('127.0.0.1')),
        isTrue,
      );
      expect(
        records.any((record) => record.message.contains('peer=[redacted]')),
        isTrue,
      );
    } finally {
      await session?.stop();
      await service?.stop();
      await subscription.cancel();
      logs.close();
      session?.dispose();
      service?.dispose();
      await root.delete(recursive: true);
    }
  });

  testWidgets(
    'native Snowflake history distinguishes listening from readiness',
    (tester) async {
      final baseline = await SnowflakeTransport.readEvents();
      try {
        final port = await SnowflakeTransport.start();
        expect(port, inInclusiveRange(1, 65535));
        expect(await SnowflakeTransport.version(), contains('2.14.1'));
        final batch = await SnowflakeTransport.readEvents(
          afterSequence: baseline.latestSequence,
        );
        expect(batch.events.map((event) => event.kind), [
          SnowflakeEventKind.starting,
          SnowflakeEventKind.listening,
        ]);
        expect(batch.events.first.generation, batch.events.last.generation);
        expect(batch.events.every((event) => !event.hasError), isTrue);
        expect(batch.dropped, 0);
      } finally {
        await SnowflakeTransport.stop();
      }
      final stopped = await SnowflakeTransport.readEvents(
        afterSequence: baseline.latestSequence,
      );
      expect(stopped.events.last.kind, SnowflakeEventKind.released);
      expect(
        (await SnowflakeTransport.readEvents(
          afterSequence: baseline.latestSequence,
        )).events.map((event) => event.sequence),
        stopped.events.map((event) => event.sequence),
      );
    },
    skip: !Platform.isAndroid && !Platform.isIOS,
  );
}
