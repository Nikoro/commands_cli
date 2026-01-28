import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['boolean']) {
    integrationTests(
      '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [true, false]
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello " when no optional param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello \n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello true" when no value for optional param is specified', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('Hello true\n'));
          });

          test('prints error when value is integer', () async {
            final result = await runCommand('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await runCommand('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error when value is string ($value)', () async {
              final result = await runCommand('hello', [flag, value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
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
    ${magenta}name (-n, --name)$reset ${gray}[boolean] Description of parameter name$reset
    ${bold}values$reset: true, false
'''));
          });
        }
      },
    );
  }

  for (String type in ['boolean']) {
    for (final invalid in [
      (value: 2, type: 'integer'),
      (value: 1.5, type: 'double'),
      (value: 'text', type: 'string'),
      (value: '"2"', type: 'string'),
      (value: '"true"', type: 'string'),
    ]) {
      integrationTests(
        '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [true, false, ${invalid.value}]
    ''',
        (runCommand) {
          for (String flag in ['-n', '--name']) {
            for (bool value in [true, false]) {
              test('prints error', () async {
                final result = await runCommand('hello', [flag, '$value']);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });
            }
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          for (String flag in ['-n', '--name']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            test('prints error', () async {
              final result = await runCommand('hello', [flag, '2']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            test('prints error', () async {
              final result = await runCommand('hello', [flag, '1.5']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
              test('prints error', () async {
                final result = await runCommand('hello', [flag, value]);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });
            }
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }
  }
}
