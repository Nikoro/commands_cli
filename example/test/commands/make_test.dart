import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('make', () {
    test('runs correctly with overridden command', () async {
      final result = await Process.run('make', []);
      expect(result.stdout, equals('make overridden\n'));
    });

    test('exits with code 0', () async {
      final result = await Process.run('make', []);
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('make', [flag]);
        expect(result.stdout, equals('${blue}make$reset\n'));
      });
    }
  });

  group('make with override: false', () {
    late File commandsYaml;
    late String originalContent;

    setUp(() {
      commandsYaml = File('commands.yaml');
      originalContent = commandsYaml.readAsStringSync();
    });

    tearDown(() {
      // Always restore original content
      commandsYaml.writeAsStringSync(originalContent);
    });

    test('executes system make command when override is false', () async {
      // Temporarily change override to false
      final modifiedContent = originalContent.replaceAll(
        'make:\n'
            '  override: true\n'
            '  script: |\n'
            '    echo "make overridden"',
        'make:\n'
            '  override: false\n'
            '  script: |\n'
            '    echo "make overridden"',
      );

      commandsYaml.writeAsStringSync(modifiedContent);

      // Run make command
      final result = await Process.run('make', []);

      // System make will fail with "No targets specified and no makefile found"
      expect(result.exitCode, equals(2));
      expect(result.stderr, contains('No targets specified and no makefile found'));
    });
  });
}
