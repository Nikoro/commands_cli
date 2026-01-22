import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['number', 'num']) {
    for (num def in [1, 1.0]) {
      integrationTests(
        '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                default: $def
    ''',
        () {
          for (String flag in ['-n', '--name']) {
            for (num value in [1, 2.0, -3, -4.7]) {
              test('prints "Hello $value', () async {
                final result = await Process.run('hello', [flag, '$value']);
                expect(result.stdout, equals('Hello $value\n'));
              });
            }
          }

          test('prints "Hello $def" when no required param is specified', () async {
            final result = await Process.run('hello', []);
            expect(result.stdout, equals('Hello $def\n'));
          });

          for (String flag in ['-n', '--name']) {
            test('prints error when no value for required param is specified', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
            });

            test('prints error when value is boolean', () async {
              final result = await Process.run('hello', [flag, 'true']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[number]$reset
   Got: true ${gray}[boolean]$reset
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
                final result = await Process.run('hello', [flag, value]);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[number]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag 3$reset
'''));
              });
            }
          }

          for (String flag in ['-h', '--help']) {
            test('$flag prints help', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name (-n, --name)$reset ${gray}[number] Description of parameter name$reset
    ${bold}default$reset: $bold${orange}$def$reset
'''));
            });
          }
        },
      );

      for (final invalid in [
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
            required:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                default: ${invalid.input}
    ''',
          () {
            for (String flag in ['-n', '--name']) {
              for (num value in [1, 2.0, -3, -4.7]) {
                test('prints error', () async {
                  final result = await Process.run('hello', [flag, '$value']);
                  expect(
                      result.stderr,
                      equals(
                          '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
                });
              }
            }

            test('prints error', () async {
              final result = await Process.run('hello', []);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });

            for (String flag in ['-n', '--name']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '2']);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '1.5']);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
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
                  final result = await Process.run('hello', [flag, value]);
                  expect(
                      result.stderr,
                      equals(
                          '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
                });
              }
            }

            for (String flag in ['-h', '--help']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[number]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });
            }
          },
        );
      }
    }
  }
}
