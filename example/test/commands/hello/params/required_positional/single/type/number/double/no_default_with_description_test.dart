import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
                type: double
    ''',
    () {
      for (double value in [1.0, 1.5, -2.7]) {
        test('prints "Hello $value', () async {
          final result = await Process.run('hello', ['$value']);
          expect(result.stdout, equals('Hello $value\n'));
        });
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
      });

      test('prints error when value is boolean', () async {
        final result = await Process.run('hello', ['true']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello 3.14$reset
'''));
      });

      test('prints error when value is integer', () async {
        final result = await Process.run('hello', ['1']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: 1 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello 3.14$reset
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
          final result = await Process.run('hello', [value]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello 3.14$reset
'''));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name$reset ${gray}[double] Description of parameter name$reset
'''));
        });
      }
    },
  );
}
