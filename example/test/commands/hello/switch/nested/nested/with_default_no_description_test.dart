import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - level1a:
              switch:
                - level2a:
                  switch:
                    - level3a:
                      script: echo "Level 1a 2a 3a"
                    - level3b:
                      script: echo "Level 1a 2a 3b"
                    - level3c:
                      script: echo "Level 1a 2a 3c"
                    - default: level3c
                - level2b:
                  script: echo "Level 1a 2b"
                - level2c:
                  script: echo "Level 1a 2c"
                - default: level2c
            - level1b:
              script: echo "Level 1b"
            - level1c:
              script: echo "Level 1c"
            - default: level1c
    ''',
    (runCommand) {
      test('runs default option when option with nested switch is not specified', () async {
        final result = await runCommand('hello', ['level1a']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      test('runs default option when option with nested switch is not specified', () async {
        final result = await runCommand('hello', ['level1a', 'level2a']);
        expect(result.stdout, equals('Level 1a 2a 3c\n'));
      });

      test('prints "Level 1a 2a 3a"', () async {
        final result = await runCommand('hello', ['level1a', 'level2a', 'level3a']);
        expect(result.stdout, equals('Level 1a 2a 3a\n'));
      });

      test('prints "Level 1a 2a 3b"', () async {
        final result = await runCommand('hello', ['level1a', 'level2a', 'level3b']);
        expect(result.stdout, equals('Level 1a 2a 3b\n'));
      });

      test('prints "Level 1a 2a 3c"', () async {
        final result = await runCommand('hello', ['level1a', 'level2a', 'level3c']);
        expect(result.stdout, equals('Level 1a 2a 3c\n'));
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
        expect(result.stdout, equals('Level 1c\n'));
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
    options:
      ${blue}level3a$reset
      ${blue}level3b$reset
      ${blue}level3c$reset
      ${bold}default$reset: ${blue}level3c$reset
    ${blue}level2b$reset
    ${blue}level2c$reset
    ${bold}default$reset: ${blue}level2c$reset
  ${blue}level1b$reset
  ${blue}level1c$reset
  ${bold}default$reset: ${blue}level1c$reset
'''));
        });
      }
    },
  );
}
