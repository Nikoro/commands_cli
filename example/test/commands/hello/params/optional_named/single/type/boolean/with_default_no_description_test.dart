import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['boolean', 'bool']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: $type 
                default: false
    ''',
      () {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await Process.run('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello false" when no optional param is specified', () async {
          final result = await Process.run('hello', []);
          expect(result.stdout, equals('Hello false\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello true" when no value for optional param is specified', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('Hello true\n'));
          });

          test('prints error when value is integer', () async {
            final result = await Process.run('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await Process.run('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
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
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[boolean]$reset
    ${bold}default$reset: "false"
'''));
          });
        }
      },
    );

    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                default: false
    ''',
      () {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await Process.run('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello false" when no optional param is specified', () async {
          final result = await Process.run('hello', []);
          expect(result.stdout, equals('Hello false\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello true" when no value for optional param is specified', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('Hello true\n'));
          });

          test('prints error when value is integer', () async {
            final result = await Process.run('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await Process.run('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
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
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[boolean]$reset
    ${bold}default$reset: "false"
'''));
          });
        }
      },
    );

    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: $type 
                default: true
    ''',
      () {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await Process.run('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello true" when no optional param is specified', () async {
          final result = await Process.run('hello', []);
          expect(result.stdout, equals('Hello true\n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello true" when no value for optional param is specified', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('Hello false\n'));
          });

          test('prints error when value is integer', () async {
            final result = await Process.run('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await Process.run('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
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
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[boolean]$reset
    ${bold}default$reset: "true"
'''));
          });
        }
      },
    );
  }
}
