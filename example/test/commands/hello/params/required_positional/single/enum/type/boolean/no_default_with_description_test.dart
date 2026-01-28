import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['boolean']) {
    for (String values in ['', '[]', '[true]', '[true, false]', '[false, true]', '[false, true, true]']) {
      integrationTests(
        '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
                type: $type
                values: $values
    ''',
        (runCommand) {
          for (bool value in [true, false]) {
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

    ${green}0. false ✓$reset
    1. true

${gray}Use arrows to navigate, 0/f for false, 1/t for true$reset
${gray}Enter to confirm, Esc to cancel$reset
'''),
            );
          });

          test('prints error when value is integer', () async {
            final result = await runCommand('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error when value is string ($value)', () async {
              final result = await runCommand('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello true$reset or $bgGreen${black}hello false$reset
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
    ${magenta}name$reset ${gray}[boolean] Description of parameter name$reset
    ${bold}values$reset: true, false
'''));
            });
          }
        },
      );
    }
  }

  for (String type in ['boolean']) {
    for (final invalid in [
      (value: 2, type: 'integer'),
      (value: 1.5, type: 'double'),
      (value: 'text', type: 'string'),
      (value: '"2"', type: 'string'),
      (value: '"true"', type: 'string'),
    ]) {
      integrationTests(
        '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
                type: $type
                values: [true, false, ${invalid.value}]
    ''',
        (runCommand) {
          for (bool value in [true, false]) {
            test('prints error', () async {
              final result = await runCommand('hello', ['$value']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          test('prints error', () async {
            final result = await runCommand('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          for (String value in ['text', '"1"', "'1.5'", '"true"', "'false'"]) {
            test('prints error', () async {
              final result = await runCommand('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }
  }
}
