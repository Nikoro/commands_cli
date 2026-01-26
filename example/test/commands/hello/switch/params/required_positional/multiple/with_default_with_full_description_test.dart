import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1: ## Description of option 1
              script: echo "Hello {name}"
              params:
                required:
                  - name ## Description of parameter name
            - opt2: ## Description of option 2
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                required:
                  - alpha: ## Description of parameter alpha
                    default: "A1"
                  - beta: ## Description of parameter beta
                    default: "B1"
                  - charlie: ## Description of parameter charlie
                    default: "C1"
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: opt3
    ''',
    () {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['opt1', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
      });

      test('prints "A: x, B: B1, C: C1"', () async {
        final result = await Process.run('hello', ['opt2', 'x']);
        expect(result.stdout, equals('A: x, B: B1, C: C1\n'));
      });

      test('prints "A: x, B: y, C: C1"', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y']);
        expect(result.stdout, equals('A: x, B: y, C: C1\n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      test('prints "A: A1, B: B1, C: C1" when no required param is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
      });

      test('prints "Option 3"', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Option 3\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset: ${gray}Description of option 1$reset
  params:
    required:
      ${magenta}name$reset ${gray}Description of parameter name$reset
  ${blue}opt2$reset: ${gray}Description of option 2$reset
  params:
    required:
      ${magenta}alpha$reset ${gray}Description of parameter alpha$reset
      ${bold}default$reset: $bold${orange}A1$reset
      ${magenta}beta$reset ${gray}Description of parameter beta$reset
      ${bold}default$reset: $bold${orange}B1$reset
      ${magenta}charlie$reset ${gray}Description of parameter charlie$reset
      ${bold}default$reset: $bold${orange}C1$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset: ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
