import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: double
                default: 1.0
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name']) {
        for (double value in [1.0, 1.5, -2.7]) {
          test('prints "Hello $value', () async {
            final result = await runCommand('hello', [flag, '$value']);
            expect(result.stdout, equals('Hello $value\n'));
          });
        }
      }

      test('prints "Hello 1.0" when no optional param is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stdout, equals('Hello 1.0\n'));
      });

      for (String flag in ['-n', '--name']) {
        test('prints "Hello 1.0" when no value for optional param is specified', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('Hello 1.0\n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', [flag, 'true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
'''));
        });

        test('prints error when value is integer', () async {
          final result = await runCommand('hello', [flag, '1']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: 1 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
'''));
        });

        for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
          test('prints error when value is string ($value)', () async {
            final result = await runCommand('hello', [flag, value]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
'''));
          });
        }
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[double] Description of parameter name$reset
    ${bold}default$reset: $bold${orange}1.0$reset
'''));
        });
      }
    },
  );

  for (final invalid in [
    (input: 1, type: 'integer'),
    (input: true, type: 'boolean'),
    (input: "'false'", type: 'string'),
    (input: '"true"', type: 'string'),
    (input: 'text', type: 'string'),
  ]) {
    integrationTests(
      '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: double
                default: ${invalid.input}
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (double value in [1.0, 1.5, -2.7]) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        }

        test('prints error', () async {
          final result = await runCommand('hello', []);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', [flag, '2']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', [flag, '1.5']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag, value]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });
        }
      },
    );
  }
}
