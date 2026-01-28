import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['integer']) {
    integrationTests(
      '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: $type
                values: [1, -3]
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (int value in [1, -3]) {
            test('prints "Hello $value', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

        test('prints "Hello " when no optional param is specified', () async {
          final result = await runCommand('hello', []);
          expect(result.stdout, equals('Hello \n'));
        });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello " when no value for optional param is specified', () async {
            final result = await runCommand('hello', ['$flag']);
            expect(result.stdout, equals('Hello \n'));
          });

          test('prints error when value is boolean', () async {
            final result = await runCommand('hello', [flag, 'true']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error when value is string ($value)', () async {
              final result = await runCommand('hello', [flag, value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "$value"
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[integer] Description of parameter name$reset
    ${bold}values$reset: 1, -3
'''));
          });
        }
      },
    );
  }
}
