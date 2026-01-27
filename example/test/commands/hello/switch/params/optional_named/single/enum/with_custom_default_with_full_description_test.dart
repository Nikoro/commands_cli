import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1: ## Description of option 1
              script: echo "Hello {name}"
              params:
                optional:
                  - name: '-n, --name, nm' ## Description of parameter name
                    values: [Alpha, Bravo, Charlie]
            - opt2: ## Description of option 2
              script: echo "Option 2"
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: ## Description of custom option
              script: echo "Custom"
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name', 'nm']) {
        for (String param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints "Hello $param"', () async {
            final result = await runCommand('hello', ['opt1', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await runCommand('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "Hello " when no value for optional param is specified', () async {
        final result = await runCommand('hello', ['opt1', '-n']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints error when invalid value for optional param is specified', () async {
        final result = await runCommand('hello', ['opt1', '-n', 'Delta']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      test('prints "Option 2"', () async {
        final result = await runCommand('hello', ['opt2']);
        expect(result.stdout, equals('Option 2\n'));
      });

      test('prints "Option 3"', () async {
        final result = await runCommand('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stdout, equals('Custom\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset: ${gray}Description of option 1$reset
  params:
    optional:
      ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
      ${bold}values$reset: Alpha, Bravo, Charlie
  ${blue}opt2$reset: ${gray}Description of option 2$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset: ${gray}Description of custom option$reset
'''));
        });
      }
    },
  );
}
