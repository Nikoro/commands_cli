import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - level1a:
              switch:
                - level2a: ## Description of level 1a 2a
                  script: echo "Hello {name}"
                  params:
                    required:
                      - name: '-n, --name, nm' ## Description of parameter name
                        values: [Alpha, Bravo, Charlie]
                        default: Charlie
                - level2b:
                  script: echo "Level 1a 2b"
                - level2c: ## Description of level 1a 2c
                  script: echo "Level 1a 2c"
                - default: level2c
            - level1b:
              script: echo "Level 1b"
            - level1c: ## Description of level 1c
              script: echo "Level 1c"
            - default: level1c
    ''',
    () {
      test('runs default option when option with nested switch is not specified', () async {
        final result = await Process.run('hello', ['level1a']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        for (String param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', ['level1a', 'level2a', flag, param]);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', ['level1a', 'level2a']);
        expect(result.stdout, equals('Hello Charlie\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no value for required param is specified', () async {
          final result = await Process.run('hello', ['level1a', 'level2a', flag]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid value for required param is specified', () async {
          final result = await Process.run('hello', ['level1a', 'level2a', flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

      test('prints "Level 1a 2b"', () async {
        final result = await Process.run('hello', ['level1a', 'level2b']);
        expect(result.stdout, equals('Level 1a 2b\n'));
      });

      test('prints "Level 1a 2c"', () async {
        final result = await Process.run('hello', ['level1a', 'level2c']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      test('prints "Level 1b"', () async {
        final result = await Process.run('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await Process.run('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Level 1c\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}level1a$reset
  options:
    ${blue}level2a$reset: ${gray}Description of level 1a 2a$reset
    params:
      required:
        ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
        ${bold}values$reset: Alpha, Bravo, Charlie
        ${bold}default$reset: "Charlie"
    ${blue}level2b$reset
    ${blue}level2c$reset: ${gray}Description of level 1a 2c$reset
    ${bold}default$reset: ${blue}level2c$reset
  ${blue}level1b$reset
  ${blue}level1c$reset: ${gray}Description of level 1c$reset
  ${bold}default$reset: ${blue}level1c$reset
'''));
        });
      }
    },
  );
}
