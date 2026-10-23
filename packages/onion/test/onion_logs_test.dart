import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';
import 'package:onion/src/rust/frb_generated.dart';

const _first = TorLogRecord(
  level: TorLogLevel.warn,
  target: 'tor_hsclient',
  message: 'descriptor fetch failed',
);
const _second = TorLogRecord(
  level: TorLogLevel.info,
  target: 'tor_circmgr',
  message: 'circuit built',
);

final class _Capture implements TorLogStream {
  final List<Completer<List<TorLogRecord>>> reads = [];
  int closeCalls = 0;

  @override
  Future<List<TorLogRecord>> nextBatch() {
    final read = Completer<List<TorLogRecord>>();
    reads.add(read);
    return read.future;
  }

  @override
  void close() {
    closeCalls++;
    for (final read in reads) {
      if (!read.isCompleted) read.complete([]);
    }
  }

  @override
  TorLogStats stats() => TorLogStats(
    accepted: BigInt.from(7),
    dropped: BigInt.from(2),
    routingDropped: BigInt.one,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Api extends OnionCoreApi {
  _Capture capture;
  final List<String?> filters = [];

  _Api(this.capture);

  @override
  TorLogStream crateApiLogOpenLogStream({String? filter}) {
    filters.add(filter);
    return capture;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _Capture capture;
  late _Api api;

  setUpAll(() {
    api = _Api(_Capture());
    OnionCore.initMock(api: api);
  });
  setUp(() {
    capture = _Capture();
    api.capture = capture;
    api.filters.clear();
  });
  tearDownAll(OnionCore.dispose);

  test('registers synchronously and can close without listening', () async {
    final logs = OnionLogs.start(filter: 'onion=debug,warn');
    expect(api.filters, ['onion=debug,warn']);
    expect(capture.reads, isEmpty);
    expect(logs.stats.accepted, BigInt.from(7));
    expect(logs.stats.dropped, BigInt.from(2));
    expect(logs.stats.routingDropped, BigInt.one);
    logs.close();
    logs.close();
    expect(capture.closeCalls, 1);
    expect(await logs.records.toList(), isEmpty);
    expect(capture.reads, isEmpty);
  });

  test(
    'delivers native batches in order and stops on an empty batch',
    () async {
      final logs = OnionLogs.start();
      final records = logs.records.toList();
      expect(api.filters, [null]);
      capture.reads.single.complete([_first, _second]);
      await _flush();
      expect(capture.reads, hasLength(2));
      capture.reads.last.complete([]);
      expect(await records, [_first, _second]);
      expect(capture.closeCalls, 1);
    },
  );

  test('pausing retains the current batch and stops further reads', () async {
    final logs = OnionLogs.start();
    final received = <TorLogRecord>[];
    late StreamSubscription<TorLogRecord> subscription;
    subscription = logs.records.listen((record) {
      received.add(record);
      if (record == _first) subscription.pause();
    });
    capture.reads.single.complete([_first, _second]);
    await _flush();
    expect(received, [_first]);
    expect(capture.reads, hasLength(1));
    subscription.resume();
    await _flush();
    expect(received, [_first, _second]);
    expect(capture.reads, hasLength(2));
    await subscription.cancel();
    expect(capture.closeCalls, 1);
  });

  test('cancelling wakes a pending native read immediately', () async {
    final logs = OnionLogs.start();
    final subscription = logs.records.listen((_) => fail('unexpected record'));
    expect(capture.reads.single.isCompleted, isFalse);
    await subscription.cancel().timeout(const Duration(seconds: 1));
    expect(capture.reads.single.isCompleted, isTrue);
    expect(capture.closeCalls, 1);
    await _flush();
    expect(capture.reads, hasLength(1));
  });

  test('closing from onData safely discards the rest of the batch', () async {
    final logs = OnionLogs.start();
    final received = <TorLogRecord>[];
    final done = Completer<void>();
    logs.records.listen((record) {
      received.add(record);
      logs.close();
    }, onDone: done.complete);
    capture.reads.single.complete([_first, _second]);
    await done.future.timeout(const Duration(seconds: 1));
    expect(received, [_first]);
    expect(capture.closeCalls, 1);
  });

  test('closing while paused releases the native capture', () async {
    final logs = OnionLogs.start();
    final subscription = logs.records.listen((_) {});
    subscription.pause();
    capture.reads.single.complete([_first]);
    await _flush();
    logs.close();
    expect(capture.closeCalls, 1);
    await subscription.cancel();
    expect(capture.reads, hasLength(1));
  });

  test('forwards a read failure to the stream and releases capture', () async {
    final logs = OnionLogs.start();
    final errors = <Object>[];
    final done = Completer<void>();
    logs.records.listen((_) {}, onError: errors.add, onDone: done.complete);
    final error = StateError('native stream unavailable');
    capture.reads.single.completeError(error);
    await done.future.timeout(const Duration(seconds: 1));
    expect(errors, [error]);
    expect(capture.closeCalls, 1);
  });
}
