import 'dart:async';

import 'rust/api/log.dart';

/// Opt-in diagnostics from the embedded Tor library, with bounded native storage.
///
/// Call [start] after `OnionCore.init()` and before `TorService.start()`. Consume [records] once, and cancel the subscription or call [close] when finished. Opening another capture replaces this one process-wide, including across Flutter engines. No record is printed, persisted, or reported here.
final class OnionLogs {
  final TorLogStream _capture;
  late final StreamController<TorLogRecord> _controller;
  Completer<void>? _resume;
  bool _closed = false;

  OnionLogs._(this._capture) {
    _controller = StreamController<TorLogRecord>(
      sync: true,
      onListen: () => unawaited(_pump()),
      onPause: () => _resume ??= Completer<void>(),
      onResume: _resumeReading,
      onCancel: close,
    );
  }

  /// Register synchronously, so the first Tor startup events can be captured.
  ///
  /// Omit [filter] for the package's diagnostic targets. Custom filters use comma-separated `target=level` directives and an optional default level. Invalid filters and `trace` throw a `TorFailure` without replacing the current capture. Calling this before `OnionCore.init()` is an error.
  factory OnionLogs.start({String? filter}) =>
      OnionLogs._(openLogStream(filter: filter));

  /// A single-subscription stream. Pausing stops native reads; up to one batch of 64 records stays in Dart and 1024 records stay in Rust. Further native events are dropped and counted, without blocking Tor.
  Stream<TorLogRecord> get records => _controller.stream;

  /// Snapshot of capture counters. Also available after [close].
  TorLogStats get stats => _capture.stats();

  /// Stop capture immediately, wake an in-flight read, and finish [records]. Idempotent; closing a replaced capture leaves its successor active.
  void close() {
    if (_closed) return;
    _closed = true;
    _capture.close();
    _resumeReading();
    // A listener may close us from inside a synchronous onData callback.
    // Finish the Dart stream after that event, while stopping Rust immediately.
    scheduleMicrotask(() => unawaited(_controller.close()));
  }

  void _resumeReading() {
    _resume?.complete();
    _resume = null;
  }

  Future<void> _pump() async {
    try {
      while (!_closed) {
        final batch = await _capture.nextBatch();
        if (batch.isEmpty) break;
        for (final record in batch) {
          var resume = _resume;
          while (resume != null) {
            await resume.future;
            resume = _resume;
          }
          if (_closed) return;
          _controller.add(record);
        }
        final resume = _resume;
        if (resume != null) await resume.future;
      }
    } catch (error, trace) {
      if (!_closed) _controller.addError(error, trace);
    } finally {
      close();
    }
  }
}
