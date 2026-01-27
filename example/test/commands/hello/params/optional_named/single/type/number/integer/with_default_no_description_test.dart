import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['integer', 'int']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: $type
                default: 1
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (int value in [1, 2, -3]) {
            test('prints "Hello $value', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello 1" when no optional param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello 1\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello 1" when no value for optional param is specified', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('Hello 1\n'));
          });

          test('prints error when value is boolean', () async {
            final result = await runCommand('hello', [flag, 'true']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello $flag 3$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await runCommand('hello', [flag, '1.0']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: 1.0 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag 3$reset
'''));
          });

          for (String value in [
            'text',
            "text",
            '"1"',
            '\"1\"',
            '\'1.5\'',
            "'1.5'",
            '\"true\"',
            '"true"',
            '\'false\'',
            "'false'"
          ]) {
            test('prints error when value is string ($value)', () async {
              final result = await runCommand('hello', [flag, value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag 3$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[integer]$reset
    ${bold}default$reset: $bold${orange}1$reset
'''));
          });
        }
      },
    );

    for (final invalid in [
      (input: 1.0, type: 'double'),
      (input: true, type: 'boolean'),
      (input: "'false'", type: 'string'),
      (input: '"true"', type: 'string'),
      (input: 'text', type: 'string'),
    ]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: $type
                default: ${invalid.input}
    ''',
        (runCommand) {
          for (String flag in ['-n', '--name']) {
            for (int value in [1, 2, -3]) {
              test('prints error', () async {
                final result = await runCommand('hello', [flag, '$value']);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });
            }
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          for (String flag in ['-n', '--name']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });

            test('prints error', () async {
              final result = await runCommand('hello', [flag, '2']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });

            test('prints error', () async {
              final result = await runCommand('hello', [flag, '1.5']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });

            for (String value in [
              'text',
              "text",
              '"1"',
              '\"1\"',
              '\'1.5\'',
              "'1.5'",
              '\"true\"',
              '"true"',
              '\'false\'',
              "'false'"
            ]) {
              test('prints error', () async {
                final result = await runCommand('hello', [flag, value]);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });
            }
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        },
      );
    }
  }
}
