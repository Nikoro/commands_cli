import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['integer', 'int']) {
    for (num def in [1, -3]) {
      integrationTests(
        '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [1, -3]
                default: $def
    ''',
        () {
          for (String flag in ['-n', '--name']) {
            for (num value in [1, -3]) {
              test('prints "Hello $value', () async {
                final result = await Process.run('hello', [flag, '$value']);
                expect(result.stdout, equals('Hello $value\n'));
              });
            }
          }

          test('prints "Hello $def" when no optional param is specified', () async {
            final result = await Process.run('hello', []);
            expect(result.stdout, equals('Hello $def\n'));
          });

          for (String flag in ['-n', '--name']) {
            test('prints "Hello $def" when no value for optional param is specified', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stdout, equals('Hello $def\n'));
            });

            test('prints error when value is boolean', () async {
              final result = await Process.run('hello', [flag, 'true']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
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
❌ Parameter $bold${red}name$reset has invalid value: "$value"
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
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
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[integer] Description of parameter name$reset
    ${bold}values$reset: 1, -3
    ${bold}default$reset: $bold${orange}$def$reset
'''));
            });
          }
        },
      );

      for (final invalid in [
        (value: true, type: 'boolean'),
        (value: "'false'", type: 'string'),
        (value: '"true"', type: 'string'),
        (value: 'text', type: 'string'),
      ]) {
        integrationTests(
          '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [1, -3, ${invalid.value}]
                default: $def
    ''',
          () {
            for (String flag in ['-n', '--name']) {
              for (num value in [1, -3]) {
                test('prints error', () async {
                  final result = await Process.run('hello', [flag, '$value']);
                  expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
                });
              }
            }

            test('prints error', () async {
              final result = await Process.run('hello', []);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            for (String flag in ['-n', '--name']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '2']);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '1.5']);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
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
                  final result = await Process.run('hello', [flag, value]);
                  expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
                });
              }
            }

            for (String flag in ['-h', '--help']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });
            }
          },
        );
      }

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
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [1, -3]
                default: ${invalid.input}
    ''',
          () {
            for (String flag in ['-n', '--name']) {
              for (num value in [1, -3]) {
                test('prints error', () async {
                  final result = await Process.run('hello', [flag, '$value']);
                  expect(
                      result.stderr,
                      equals(
                          '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
                });
              }
            }

            test('prints error', () async {
              final result = await Process.run('hello', []);
              expect(
                  result.stderr,
                  equals(
                      '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
            });

            for (String flag in ['-n', '--name']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '2']);
                expect(
                    result.stderr,
                    equals(
                        '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
              });

              test('prints error', () async {
                final result = await Process.run('hello', [flag, '1.5']);
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
                  final result = await Process.run('hello', [flag, value]);
                  expect(
                      result.stderr,
                      equals(
                          '❌ Parameter $bold${red}name$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[${invalid.type}]$reset\n'));
                });
              }
            }

            for (String flag in ['-h', '--help']) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag]);
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
}
