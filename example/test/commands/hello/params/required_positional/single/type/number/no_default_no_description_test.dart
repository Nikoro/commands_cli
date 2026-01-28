import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['number']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name:
                type: $type
    ''',
      (runCommand) {
        for (num value in [1, 2.0, -3, -4.7]) {
          test('prints "Hello $value', () async {
            final result = await runCommand('hello', ['$value']);
            expect(result.stdout, equals('Hello $value\n'));
          });
        }

        test('prints error when no required param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', ['true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[number]$reset
   Got: true ${gray}[boolean]$reset
💡 Example: $bgGreen${black}hello 3$reset
'''));
        });

        for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
          test('prints error when value is string ($value)', () async {
            final result = await runCommand('hello', [value]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[number]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello 3$reset
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
    ${magenta}name$reset ${gray}[number]$reset
'''));
          });
        }
      },
    );
  }
}
