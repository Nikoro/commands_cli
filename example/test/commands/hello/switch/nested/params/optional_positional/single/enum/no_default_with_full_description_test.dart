import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - level1a: ## Description of level 1a
              switch:
                - level2a: ## Description of level 1a 2a
                  script: echo "Hello {name}"
                  params:
                    optional:
                      - name: ## Description of parameter name
                        values: [Alpha, Bravo, Charlie]
                - level2b: ## Description of level 1a 2b
                  script: echo "Level 1a 2b"
                - level2c: ## Description of level 1a 2c
                  script: echo "Level 1a 2c"
            - level1b: ## Description of level 1b
              script: echo "Level 1b"
            - level1c: ## Description of level 1c
              script: echo "Level 1c"
    ''',
    (runCommand) {
      test('shows interactive picker when option with nested switch is not specified', () async {
        final result = await runCommand('hello', ['level1a']);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello level1a$reset:

    ${green}1. level2a ✓$reset ${gray}- Description of level 1a 2a$reset
    2. level2b   ${gray}- Description of level 1a 2b$reset
    3. level2c   ${gray}- Description of level 1a 2c$reset

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String param in ['Alpha', 'Bravo', 'Charlie']) {
        test('prints "Hello $param"', () async {
          final result = await runCommand('hello', ['level1a', 'level2a', param]);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await runCommand('hello', ['level1a', 'level2a']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints error when invalid value for optional param is specified', () async {
        final result = await runCommand('hello', ['level1a', 'level2a', 'Delta']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      test('prints "Level 1a 2b"', () async {
        final result = await runCommand('hello', ['level1a', 'level2b']);
        expect(result.stdout, equals('Level 1a 2b\n'));
      });

      test('prints "Level 1a 2c"', () async {
        final result = await runCommand('hello', ['level1a', 'level2c']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      test('prints "Level 1b"', () async {
        final result = await runCommand('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await runCommand('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('shows interactive picker when no option is specified', () async {
        final result = await runCommand('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. level1a ✓$reset ${gray}- Description of level 1a$reset
    2. level1b   ${gray}- Description of level 1b$reset
    3. level1c   ${gray}- Description of level 1c$reset

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}level1a$reset: ${gray}Description of level 1a$reset
  options:
    ${blue}level2a$reset: ${gray}Description of level 1a 2a$reset
    params:
      optional:
        ${magenta}name$reset ${gray}Description of parameter name$reset
        ${bold}values$reset: Alpha, Bravo, Charlie
    ${blue}level2b$reset: ${gray}Description of level 1a 2b$reset
    ${blue}level2c$reset: ${gray}Description of level 1a 2c$reset
  ${blue}level1b$reset: ${gray}Description of level 1b$reset
  ${blue}level1c$reset: ${gray}Description of level 1c$reset
'''));
        });
      }
    },
  );
}
