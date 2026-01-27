import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha:
                values: [A1, A2, A3]
              - beta:
              - charlie: ## Description of parameter charlie
    ''',
    (runCommand) {
      test('prints error when no required param is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stderr,
            equals('❌ Missing required positional params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });
      for (String value in ['A1', 'A2', 'A3']) {
        test('prints error when required param is not specified', () async {
          final result = await runCommand('hello', [value]);
          expect(result.stderr,
              equals('❌ Missing required positional params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
        });

        test('prints error when required param is not specified', () async {
          final result = await runCommand('hello', [value, 'y']);
          expect(result.stderr, equals('❌ Missing required positional param: $bold${red}charlie$reset\n'));
        });

        test('prints "A: $value, B: y, C: z"', () async {
          final result = await runCommand('hello', [value, 'y', 'z']);
          expect(result.stdout, equals('A: $value, B: y, C: z\n'));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha$reset
    ${bold}values$reset: A1, A2, A3
    ${magenta}beta$reset
    ${magenta}charlie$reset ${gray}Description of parameter charlie$reset
'''));
        });
      }
    },
  );
}
