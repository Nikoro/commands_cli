import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String def in ['charlie', "'charlie'", '"charlie"']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: string
                values: [alpha, 'bravo', "charlie"]
                default: $def
    ''',
      (runCommand) {
        for (String value in ['alpha', 'bravo', 'charlie']) {
          test('prints "Hello $value', () async {
            final result = await runCommand('hello', ['$value']);
            expect(result.stdout, equals('Hello $value\n'));
          });
        }

        test('prints "Hello charlie" when no required param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello charlie\n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', ['true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });

        test('prints error when value is integer', () async {
          final result = await runCommand('hello', ['2']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "2"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });

        test('prints error when value is double', () async {
          final result = await runCommand('hello', ['1.5']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "1.5"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name$reset ${gray}[string]$reset
    ${bold}values$reset: alpha, bravo, charlie
    ${bold}default$reset: $bold${orange}charlie$reset
'''));
          });
        }
      },
    );

    for (final invalid in [
      (value: 2, type: 'integer'),
      (value: 1.5, type: 'double'),
      (value: true, type: 'boolean'),
    ]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: string
                values: [alpha, 'bravo', "charlie", ${invalid.value}]
                default: $def
    ''',
        (runCommand) {
          for (bool value in [true, false]) {
            test('prints error', () async {
              final result = await runCommand('hello', ['$value']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error', () async {
              final result = await runCommand('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }
  }

  for (final invalid in [
    (input: 1, type: 'integer'),
    (input: 1.5, type: 'double'),
    (input: true, type: 'boolean'),
  ]) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: string
                values: [alpha, 'bravo', "charlie"]
                default: ${invalid.input}
    ''',
      (runCommand) {
        for (String value in ['alpha', 'bravo', 'charlie']) {
          test('prints error', () async {
            final result = await runCommand('hello', ['$value']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });
        }

        test('prints error', () async {
          final result = await runCommand('hello', []);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        test('prints error', () async {
          final result = await runCommand('hello', ['true']);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        test('prints error', () async {
          final result = await runCommand('hello', ['2']);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        test('prints error', () async {
          final result = await runCommand('hello', ['1.5']);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        for (String flag in ['-h', '--help']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });
        }
      },
    );
  }
}
