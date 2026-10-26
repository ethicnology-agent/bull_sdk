import 'rust/api/client.dart' as native;
import 'rust/api/error.dart';

/// Immutable startup settings with checked unsigned integers at the Dart edge.
///
/// Invalid integers fail during construction, before any FFI encoder can
/// allocate native arguments. Rust then checks setting-specific constraints.
final class TorStartupSettings extends native.TorStartupSettings {
  factory TorStartupSettings({
    BigInt? connectTimeoutMs,
    required bool disablePreemptiveExitCircuits,
    BigInt? streamOpenTimeoutMs,
    BigInt? memoryQuotaBytes,
  }) => TorStartupSettings._(
    connectTimeoutMs: _checked(connectTimeoutMs),
    disablePreemptiveExitCircuits: disablePreemptiveExitCircuits,
    streamOpenTimeoutMs: _checked(streamOpenTimeoutMs),
    memoryQuotaBytes: _checked(memoryQuotaBytes),
  );

  const TorStartupSettings._({
    super.connectTimeoutMs,
    required super.disablePreemptiveExitCircuits,
    super.streamOpenTimeoutMs,
    super.memoryQuotaBytes,
  });

  static Future<TorStartupSettings> default_() async {
    final settings = await native.TorStartupSettings.default_();
    return TorStartupSettings(
      connectTimeoutMs: settings.connectTimeoutMs,
      disablePreemptiveExitCircuits: settings.disablePreemptiveExitCircuits,
      streamOpenTimeoutMs: settings.streamOpenTimeoutMs,
      memoryQuotaBytes: settings.memoryQuotaBytes,
    );
  }

  static BigInt? _checked(BigInt? value) {
    if (value != null && (value.isNegative || value.bitLength > 64)) {
      throw const TorFailure(
        kind: TorFailureKind.configuration,
        logMessage: 'Startup limit must fit an unsigned 64-bit integer',
      );
    }
    return value;
  }
}
