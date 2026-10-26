import 'rust/api/client.dart' as native;
import 'rust/api/error.dart';

/// Immutable startup settings with checked unsigned integers at the Dart edge.
///
/// Values retain their BigInt representation until the generated encoder reads
/// them. Invalid integers throw a configuration failure before reaching FFI;
/// native validation still checks each setting's domain and platform limits.
final class TorStartupSettings extends native.TorStartupSettings {
  const TorStartupSettings({
    super.connectTimeoutMs,
    required super.disablePreemptiveExitCircuits,
    super.streamOpenTimeoutMs,
    super.memoryQuotaBytes,
  });

  /// Total budget of the default SOCKS listener; other sessions keep theirs.
  @override
  BigInt? get connectTimeoutMs => _checked(super.connectTimeoutMs);

  /// Client-wide stream-opening budget after circuit acquisition, in milliseconds.
  @override
  BigInt? get streamOpenTimeoutMs => _checked(super.streamOpenTimeoutMs);

  /// Approximate tracked queue limit in bytes, not a process RSS ceiling.
  @override
  BigInt? get memoryQuotaBytes => _checked(super.memoryQuotaBytes);

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
