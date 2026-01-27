import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
                type: double
                values: [2.0, -4.7]
    ''',
    (runCommand) {
      for (double value in [2.0, -4.7]) {
        test('prints "Hello $value', () async {
          final result = await runCommand('hello', ['$value']);
          expect(result.stdout, equals('Hello $value\n'));
        });
      }

      test('shows interactive picker when no required param is specified', () async {
        final result = await runCommand('hello', []);
        expect(
          result.stdout,
          equals('''

Select value for ${blue}name$reset:
${gray}Description of parameter name$reset

    ${green}1. 2.0  ✓$reset
    2. -4.7  

${gray}Press number (1-2) or press Esc to cancel:$reset
'''),
        );
      });

      test('prints error when value is boolean', () async {
        final result = await runCommand('hello', ['true']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
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
          final result = await runCommand('hello', [value]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "$value"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
'''));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name$reset ${gray}[double] Description of parameter name$reset
    ${bold}values$reset: 2.0, -4.7
'''));
        });
      }
    },
  );
}
