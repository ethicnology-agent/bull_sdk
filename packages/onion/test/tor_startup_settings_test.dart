import 'package:flutter_test/flutter_test.dart';
import 'package:onion/onion.dart';

void main() {
  final constructors = <String, TorStartupSettings Function(BigInt)>{
    'listener timeout': (value) => TorStartupSettings(
      connectTimeoutMs: value,
      disablePreemptiveExitCircuits: false,
    ),
    'stream timeout': (value) => TorStartupSettings(
      streamOpenTimeoutMs: value,
      disablePreemptiveExitCircuits: false,
    ),
    'queue quota': (value) => TorStartupSettings(
      memoryQuotaBytes: value,
      disablePreemptiveExitCircuits: false,
    ),
  };

  for (final entry in constructors.entries) {
    test('rejects invalid ${entry.key} before native initialization', () {
      for (final value in [BigInt.from(-2), BigInt.one << 64]) {
        expect(
          () {
            entry.value(value);
          },
          throwsA(
            isA<TorFailure>().having(
              (failure) => failure.kind,
              'kind',
              TorFailureKind.configuration,
            ),
          ),
        );
      }
    });
  }

  test('preserves omitted settings and representable values', () {
    final defaults = TorStartupSettings(disablePreemptiveExitCircuits: false);
    expect(defaults.connectTimeoutMs, isNull);
    expect(defaults.streamOpenTimeoutMs, isNull);
    expect(defaults.memoryQuotaBytes, isNull);
    final maximum = (BigInt.one << 64) - BigInt.one;
    final settings = TorStartupSettings(
      connectTimeoutMs: maximum,
      streamOpenTimeoutMs: BigInt.from(20000),
      memoryQuotaBytes: BigInt.from(134217728),
      disablePreemptiveExitCircuits: true,
    );
    expect(settings.connectTimeoutMs, maximum);
    expect(settings.streamOpenTimeoutMs, BigInt.from(20000));
    expect(settings.memoryQuotaBytes, BigInt.from(134217728));
  });
}
