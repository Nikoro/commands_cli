import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['boolean']) {
    for (bool def in [true, false]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: $type
                values: [true, false] 
                default: $def
    ''',
        (runCommand) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await runCommand('hello', ['$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }

          test('prints "Hello $def" when no required param is specified', () async {
            final result = await runCommand('hello', []);
            expect(result.stdout, equals('Hello $def\n'));
          });

          test('prints error when value is integer', () async {
            final result = await runCommand('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error when value is string ($value)', () async {
              final result = await runCommand('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
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
    ${magenta}name$reset ${gray}[boolean]$reset
    ${bold}values$reset: true, false
    ${bold}default$reset: $bold${orange}$def$reset
'''));
            });
          }
        },
      );
    }

    for (final invalid in [
      (input: 1, type: 'integer'),
      (input: 1.5, type: 'double'),
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
                type: $type
                values: [true, false] 
                default: ${invalid.input}
    ''',
        (runCommand) {
          for (bool value in [true, false]) {
            test('prints error', () async {
              final result = await runCommand('hello', ['$value']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['2']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error', () async {
              final result = await runCommand('hello', [value]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        },
      );
    }
  }
}
