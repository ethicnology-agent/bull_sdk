import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

/// Process-wide Snowflake pluggable transport supplied by IPtProxy on mobile.
abstract final class SnowflakeTransport {
  static const MethodChannel _channel = MethodChannel(
    'com.bullbitcoin.onion/snowflake',
  );

  static Future<int>? _starting;
  static int? _port;

  /// Acquires this Flutter engine's lease and returns the loopback SOCKS port.
  static Future<int> start() {
    _ensureSupported();
    final port = _port;
    if (port != null) return Future.value(port);
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  /// Releases this Flutter engine's lease.
  static Future<void> stop() async {
    _ensureSupported();
    final starting = _starting;
    if (starting != null) {
      try {
        await starting;
      } on Object {
        return;
      }
    }
    if (_port == null) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } finally {
      _port = null;
    }
  }

  /// Version embedded in the resolved IPtProxy binary.
  static Future<String> version() async {
    _ensureSupported();
    final version = await _channel.invokeMethod<String>('version');
    if (version == null || version.isEmpty) {
      throw StateError('IPtProxy did not report its Snowflake version');
    }
    return version;
  }

  /// Reads at most 64 process-local native events without consuming other readers' history.
  ///
  /// Pass the previous batch's [SnowflakeEventBatch.latestSequence] to continue.
  /// Cursors reset on process restart; [SnowflakeEventBatch.dropped] reports overwritten events.
  static Future<SnowflakeEventBatch> readEvents({int afterSequence = 0}) async {
    _ensureSupported();
    if (afterSequence < 0) {
      throw ArgumentError('Snowflake event cursor must be nonnegative');
    }
    final response = await _channel.invokeMethod<Object?>('readEvents', {
      'afterSequence': afterSequence,
    });
    return SnowflakeEventBatch._decode(response, afterSequence);
  }

  static Future<int> _start() async {
    final port = await _channel.invokeMethod<int>('start');
    if (port == null || port < 1 || port > 65535) {
      throw StateError('IPtProxy did not bind a valid Snowflake port');
    }
    _port = port;
    return port;
  }

  static void _ensureSupported() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw UnsupportedError('Snowflake is supported on Android and iOS');
    }
  }
}

/// A native Snowflake milestone, independent of Arti bootstrap readiness.
enum SnowflakeEventKind {
  starting,

  /// The local SOCKS listener is bound; no remote connection is implied.
  listening,

  /// A connection to a Snowflake proxy succeeded.
  connected,

  /// Discovery or an established WebRTC connection failed; the native callback does not identify the phase.
  transportError,

  /// One connection stopped; the local listener may still be available.
  connectionStopped,

  /// The last native lease was released and teardown was requested.
  released,
  startFailed,

  /// A newer native library supplied an unrecognized milestone.
  unknown,
}

/// Safe metadata only; native error messages and addresses are never included.
final class SnowflakeEvent {
  final int sequence;

  /// Identifies a controller attempt, including callbacks arriving after teardown.
  final int generation;

  /// Monotonic milliseconds since this controller attempt began.
  final int elapsedMs;
  final SnowflakeEventKind kind;
  final bool hasError;

  const SnowflakeEvent._({
    required this.sequence,
    required this.generation,
    required this.elapsedMs,
    required this.kind,
    required this.hasError,
  });
}

/// An immutable snapshot of the bounded native history.
final class SnowflakeEventBatch {
  final List<SnowflakeEvent> events;
  final int latestSequence;
  final int dropped;

  const SnowflakeEventBatch._(this.events, this.latestSequence, this.dropped);

  static SnowflakeEventBatch _decode(Object? value, int cursor) {
    Never invalid() =>
        throw const FormatException('Invalid Snowflake event batch');
    if (value is! Map) invalid();
    final latest = value['latestSequence'];
    final dropped = value['dropped'];
    final records = value['events'];
    if (latest is! int ||
        latest < cursor ||
        dropped is! int ||
        dropped < 0 ||
        records is! List ||
        records.length > 64 ||
        latest - cursor != dropped + records.length) {
      invalid();
    }
    final events = <SnowflakeEvent>[];
    var previous = cursor + dropped;
    for (final record in records) {
      if (record is! Map) invalid();
      final sequence = record['sequence'];
      final generation = record['generation'];
      final elapsedMs = record['elapsedMs'];
      final kind = record['kind'];
      final hasError = record['hasError'];
      if (sequence is! int ||
          sequence != previous + 1 ||
          generation is! int ||
          generation < 1 ||
          elapsedMs is! int ||
          elapsedMs < 0 ||
          kind is! String ||
          hasError is! bool) {
        invalid();
      }
      events.add(
        SnowflakeEvent._(
          sequence: sequence,
          generation: generation,
          elapsedMs: elapsedMs,
          kind: SnowflakeEventKind.values.firstWhere(
            (value) => value.name == kind,
            orElse: () => SnowflakeEventKind.unknown,
          ),
          hasError: hasError,
        ),
      );
      previous = sequence;
    }
    return SnowflakeEventBatch._(List.unmodifiable(events), latest, dropped);
  }
}
