import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['integer', 'int']) {
    integrationTests(
      '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
    ''',
      () {
        for (String flag in ['-n', '--name']) {
          for (int value in [1, 2, -3]) {
            test('prints "Hello $value', () async {
              final result = await Process.run('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello " when no optional param is specified', () async {
          final result = await Process.run('hello', []);
          expect(result.stdout, equals('Hello \n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello " when no value for optional param is specified', () async {
            final result = await Process.run('hello', ['$flag']);
            expect(result.stdout, equals('Hello \n'));
          });

          test('prints error when value is boolean', () async {
            final result = await Process.run('hello', [flag, 'true']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello $flag 3$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await Process.run('hello', [flag, '1.0']);
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
              final result = await Process.run('hello', [flag, value]);
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
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[integer] Description of parameter name$reset
'''));
          });
        }
      },
    );
  }
}
