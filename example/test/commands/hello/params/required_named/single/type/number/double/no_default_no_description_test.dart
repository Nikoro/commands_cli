import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name'
                type: double
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name']) {
        for (double value in [1.0, 1.5, -2.7]) {
          test('prints "Hello $value', () async {
            final result = await runCommand('hello', [flag, '$value']);
            expect(result.stdout, equals('Hello $value\n'));
          });
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
      });

      for (String flag in ['-n', '--name']) {
        test('prints error when no value for required param is specified', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', [flag, 'true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
'''));
        });

        test('prints error when value is integer', () async {
          final result = await runCommand('hello', [flag, '1']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: 1 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
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
            final result = await runCommand('hello', [flag, value]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[double]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag 3.14$reset
'''));
          });
        }
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n, --name)$reset ${gray}[double]$reset
'''));
        });
      }
    },
  );
}
