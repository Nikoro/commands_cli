import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1:
              script: echo "Hello {name}"
              params:
                required:
                  - name: '-n, --name, nm' ## Description of parameter name
            - opt2:
              script: echo "Option 2"
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: opt3
    ''',
    (runCommand) {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await runCommand('hello', ['opt1', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await runCommand('hello', ['opt1']);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
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
        expect(result.stdout, equals('Option 3\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset
  params:
    required:
      ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
  ${blue}opt2$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset: ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
