import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name' ## Description of parameter name
                type: string
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name']) {
        for (Object value in [1.5, 2, true, 'World']) {
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
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name (-n, --name)$reset ${gray}[string] Description of parameter name$reset
'''));
        });
      }
    },
  );
}
