import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

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
                      - name ## Description of parameter name
                - level2b: ## Description of level 1a 2b
                  script: echo "Level 1a 2b"
                - level2c: ## Description of level 1a 2c
                  script: echo "Level 1a 2c"
                - default: ## Description of level 1a Custom
                  script: echo "Level 1a Custom"                 
            - level1b: ## Description of level 1b
              script: echo "Level 1b"
            - level1c: ## Description of level 1c
              script: echo "Level 1c"
            - default: ## Description of Custom
              script: echo "Custom"
    ''',
    () {
      test('runs default option when option with nested switch is not specified', () async {
        final result = await Process.run('hello', ['level1a']);
        expect(result.stdout, equals('Level 1a Custom\n'));
      });

      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['level1a', 'level2a', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', ['level1a', 'level2a']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "Level 1a 2b"', () async {
        final result = await Process.run('hello', ['level1a', 'level2b']);
        expect(result.stdout, equals('Level 1a 2b\n'));
      });

      test('prints "Level 1a 2c"', () async {
        final result = await Process.run('hello', ['level1a', 'level2c']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      test('prints "Level 1b"', () async {
        final result = await Process.run('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await Process.run('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Custom\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}level1a$reset: ${gray}Description of level 1a$reset
  options:
    ${blue}level2a$reset: ${gray}Description of level 1a 2a$reset
    params:
      optional:
        ${magenta}name$reset ${gray}Description of parameter name$reset
    ${blue}level2b$reset: ${gray}Description of level 1a 2b$reset
    ${blue}level2c$reset: ${gray}Description of level 1a 2c$reset
    ${bold}default$reset: ${gray}Description of level 1a Custom$reset
  ${blue}level1b$reset: ${gray}Description of level 1b$reset
  ${blue}level1c$reset: ${gray}Description of level 1c$reset
  ${bold}default$reset: ${gray}Description of Custom$reset
'''));
        });
      }
    },
  );
}
