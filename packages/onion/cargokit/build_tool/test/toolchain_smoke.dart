// Run with `dart run test/toolchain_smoke.dart` after resolving dependencies.
// Uses the production command seam; never invokes or installs a toolchain.
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../lib/src/builder.dart';
import '../lib/src/cargo.dart';
import '../lib/src/options.dart';
import '../lib/src/rustup.dart';
import '../lib/src/target.dart';
import '../lib/src/util.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  var failures = 0;
  Future<void> test(String name, Future<void> Function() body) async {
    try {
      await body();
      stdout.writeln('PASS $name');
    } catch (error, stack) {
      failures++;
      stderr.writeln('FAIL $name: $error\n$stack');
    } finally {
      testRunCommandOverride = null;
    }
  }

  final calls = <TestRunCommandArgs>[];
  void mockRustup() {
    calls.clear();
    testRunCommandOverride = (args) {
      calls.add(args);
      check(args.executable == 'rustup', 'Only fake rustup commands expected');
      final command = args.arguments.join(' ');
      if (command == 'show active-toolchain') {
        check(
          args.workingDirectory == '/fixture/crate',
          'Toolchain must resolve from the crate directory',
        );
        check(
          args.environment?['RUSTUP_AUTO_INSTALL'] == '0',
          'Selection must not install a toolchain',
        );
        return TestRunCommandResult(
          stdout:
              '1.95.0-x86_64-unknown-linux-gnu (overridden by rust-toolchain.toml)\n',
        );
      }
      if (command == 'toolchain list') {
        return TestRunCommandResult(
          stdout: '''stable-x86_64-unknown-linux-gnu (default)
1.95.0-x86_64-unknown-linux-gnu
nightly-2026-09-01-x86_64-unknown-linux-gnu
custom-local
''',
        );
      }
      if (args.arguments.take(2).join(' ') == 'target list') {
        check(args.arguments.contains('--installed'), 'Installed targets only');
        return TestRunCommandResult(stdout: 'x86_64-unknown-linux-gnu\n');
      }
      if (args.arguments.firstOrNull == 'run') {
        return TestRunCommandResult();
      }
      throw StateError('Unexpected command (possible install): $command');
    };
  }

  RustBuilder builder(CargokitCrateOptions options) => RustBuilder(
    target: Target(rust: 'x86_64-unknown-linux-gnu'),
    environment: BuildEnvironment(
      configuration: BuildConfiguration.debug,
      crateOptions: options,
      targetTempDir: '/fixture/output',
      manifestDir: '/fixture/crate',
      crateInfo: CrateInfo(packageName: 'fixture'),
      isAndroid: false,
    ),
  );

  await test(
    'implicit selection builds with the crate active toolchain',
    () async {
      mockRustup();
      final subject = builder(CargokitCrateOptions());
      await subject.build();
      final run = calls.singleWhere((c) => c.arguments.first == 'run');
      check(
        run.arguments[1] == '1.95.0-x86_64-unknown-linux-gnu',
        'Expected pinned 1.95.0, got ${run.arguments[1]}',
      );
    },
  );

  await test('flags without a toolchain preserve the project pin', () async {
    mockRustup();
    final options = CargokitCrateOptions.parse(
      loadYamlNode('''cargo:
  debug:
    extra_flags: [--locked]
'''),
    );
    await builder(options).build();
    final run = calls.singleWhere((c) => c.arguments.first == 'run');
    check(
      run.arguments[1] == '1.95.0-x86_64-unknown-linux-gnu',
      'Flags-only config must not select ${run.arguments[1]}',
    );
    check(run.arguments.contains('--locked'), 'Preserve Cargo flags');
  });

  await test('explicit stable overrides the project pin', () async {
    mockRustup();
    final options = CargokitCrateOptions.parse(
      loadYamlNode('''cargo:
  debug:
    toolchain: stable
'''),
    );
    await builder(options).build();
    final run = calls.singleWhere((c) => c.arguments.first == 'run');
    check(run.arguments[1] == 'stable', 'Explicit stable must win');
    check(
      !calls.any((c) => c.arguments.join(' ') == 'show active-toolchain'),
      'Explicit configuration must not resolve the project pin',
    );
  });

  await test(
    'installed numeric pins are reused without installation',
    () async {
      mockRustup();
      final rustup = Rustup();
      check(
        rustup
                .installedTargets('1.95.0')
                ?.contains('x86_64-unknown-linux-gnu') ==
            true,
        'Installed numeric toolchain was discarded',
      );
      final subject = builder(CargokitCrateOptions());
      subject.prepare(rustup);
      await subject.build();
      check(
        calls
                .where((c) => c.arguments.join(' ') == 'show active-toolchain')
                .length ==
            1,
        'Prepare and build must share one resolved toolchain',
      );
    },
  );

  await test(
    'missing active selection fails without compiling stable',
    () async {
      calls.clear();
      testRunCommandOverride = (args) {
        calls.add(args);
        check(
          args.arguments.join(' ') == 'show active-toolchain',
          'Do not fall back to another compiler',
        );
        return TestRunCommandResult(stdout: '  \n');
      };
      Object? failure;
      try {
        await builder(CargokitCrateOptions()).build();
      } catch (error) {
        failure = error;
      }
      check(failure is StateError, 'An absent active compiler must fail');
      check(calls.length == 1, 'Only one read-only selection query expected');
    },
  );

  if (failures != 0) exitCode = 1;
}
