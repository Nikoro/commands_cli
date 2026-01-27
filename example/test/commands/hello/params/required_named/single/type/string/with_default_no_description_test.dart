import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  for (String def in ['text', "'text'", '"text"']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name'
                type: string
                default: $def
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (Object value in [1.5, 2, true, 'World']) {
            test('prints "Hello $value', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello text" when no required param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello text\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints error when no value for required param is specified', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
          });
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n, --name)$reset ${gray}[string]$reset
    ${bold}default$reset: $bold${orange}text$reset
'''));
          });
        }
      },
    );
  }

  for (final invalid in [
    (input: 1, type: 'integer'),
    (input: true, type: 'boolean'),
    (input: 2.0, type: 'double'),
  ]) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name'
                type: string
                default: ${invalid.input}
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (Object value in [1.5, 2, true, 'World']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        }

        test('prints error', () async {
          final result = await runCommand('hello', []);
          expect(
              result.stderr,
              equals(
                  '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(
                result.stderr,
                equals(
                    '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
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
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });
          }
        }

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
