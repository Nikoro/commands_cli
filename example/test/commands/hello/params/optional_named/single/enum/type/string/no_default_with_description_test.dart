import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: string
                values: [alpha, 'bravo', "charlie"]
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name']) {
        for (String value in ['alpha', 'bravo', 'charlie']) {
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
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('Hello \n'));
        });

        test('prints error when value is boolean', () async {
          final result = await runCommand('hello', [flag, 'true']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });

        test('prints error when value is integer', () async {
          final result = await runCommand('hello', [flag, '2']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "2"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });

        test('prints error when value is double', () async {
          final result = await runCommand('hello', [flag, '1.5']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "1.5"
💡 Must be one of: $bold${green}alpha$reset, $bold${green}bravo$reset, $bold${green}charlie$reset
'''));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name (-n, --name)$reset ${gray}[string] Description of parameter name$reset
    ${bold}values$reset: alpha, bravo, charlie
'''));
        });
      }
    },
  );

  for (final invalid in [
    (value: 2, type: 'integer'),
    (value: 1.5, type: 'double'),
    (value: true, type: 'boolean'),
  ]) {
    integrationTests(
      '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name' ## Description of parameter name
                type: string
                values: [alpha, 'bravo', "charlie", ${invalid.value}]
    ''',
      (runCommand) {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints error', () async {
              final result = await runCommand('hello', [flag, '$value']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        }

        test('prints error', () async {
          final result = await runCommand('hello', []);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
        });

        for (String flag in ['-n', '--name']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await runCommand('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
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
              final result = await runCommand('hello', [flag, value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('prints error', () async {
            final result = await runCommand('hello', [flag]);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[string]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });
        }
      },
    );
  }
}
