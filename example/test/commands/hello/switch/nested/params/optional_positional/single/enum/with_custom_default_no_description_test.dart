import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - level1a:
              switch:
                - level2a:
                  script: echo "Hello {name}"
                  params:
                    optional:
                      - name:
                        values: [Alpha, Bravo, Charlie]
                - level2b:
                  script: echo "Level 1a 2b"
                - level2c:
                  script: echo "Level 1a 2c"
                - default:
                  script: echo "Level 1a Custom"
            - level1b:
              script: echo "Level 1b"
            - level1c:
              script: echo "Level 1c"
            - default:
              script: echo "Custom"
    ''',
    (runCommand) {
      test('runs default option when option with nested switch is not specified', () async {
        final result = await runCommand('hello', ['level1a']);
        expect(result.stdout, equals('Level 1a Custom\n'));
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

      test('runs default option when no option is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stdout, equals('Custom\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}level1a$reset
  options:
    ${blue}level2a$reset
    params:
      optional:
        ${magenta}name$reset
        ${bold}values$reset: Alpha, Bravo, Charlie
    ${blue}level2b$reset
    ${blue}level2c$reset
    ${bold}default$reset
  ${blue}level1b$reset
  ${blue}level1c$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
