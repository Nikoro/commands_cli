import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  for (double def in [2.0, -4.7]) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: double
                values: [2.0, -4.7]
                default: $def
    ''',
      (runCommand) {
        for (double value in [2.0, -4.7]) {
          test('prints "Hello $value', () async {
            final result = await runCommand('hello', ['$value']);
            expect(result.stdout, equals('Hello $value\n'));
          });
        }

        test('prints "Hello $def" when no required param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello $def\n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', ['true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
'''));
        });

        test('prints error when value is integer', () async {
          final result = await runCommand('hello', ['1']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "1"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
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
            final result = await runCommand('hello', [value]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "$value"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
'''));
          });
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name$reset ${gray}[double]$reset
    ${bold}values$reset: 2.0, -4.7
    ${bold}default$reset: $bold${orange}$def$reset
'''));
          });
        }
      },
    );

    for (final invalid in [
      (value: true, type: 'boolean'),
      (value: 1, type: 'integer'),
      (value: "'false'", type: 'string'),
      (value: '"true"', type: 'string'),
      (value: 'text', type: 'string'),
    ]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: double
                values: [2.0, -4.7, ${invalid.value}]
                default: $def
    ''',
        (runCommand) {
          for (double value in [2.0, -4.7]) {
            test('prints error', () async {
              final result = await runCommand('hello', ['$value']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
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
            test('prints error', () async {
              final result = await runCommand('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }

    for (final invalid in [
      (input: true, type: 'boolean'),
      (input: 1, type: 'integer'),
      (input: "'false'", type: 'string'),
      (input: '"true"', type: 'string'),
      (input: 'text', type: 'string'),
    ]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: double
                values: [2.0, -4.7]
                default: ${invalid.input}
    ''',
        (runCommand) {
          for (double value in [2.0, -4.7]) {
            test('prints error', () async {
              final result = await runCommand('hello', ['$value']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['2']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
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
              final result = await runCommand('hello', [value]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
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
}
