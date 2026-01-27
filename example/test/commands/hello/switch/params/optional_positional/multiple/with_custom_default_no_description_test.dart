import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - opt1:
              script: echo "Hello {name}"
              params:
                optional:
                  - name
            - opt2:
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                optional:
                  - alpha
                  - beta
                  - charlie
            - opt3:
              script: echo "Option 3"
            - default:
              script: echo "Custom"
    ''',
    (runCommand) {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await runCommand('hello', ['opt1', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await runCommand('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "A: x, B: , C: "', () async {
        final result = await runCommand('hello', ['opt2', 'x']);
        expect(result.stdout, equals('A: x, B: , C: \n'));
      });

      test('prints "A: x, B: y, C: "', () async {
        final result = await runCommand('hello', ['opt2', 'x', 'y']);
        expect(result.stdout, equals('A: x, B: y, C: \n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await runCommand('hello', ['opt2', 'x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await runCommand('hello', ['opt2']);
        expect(result.stdout, equals('A: , B: , C: \n'));
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
${blue}hello$reset
options:
  ${blue}opt1$reset
  params:
    optional:
      ${magenta}name$reset
  ${blue}opt2$reset
  params:
    optional:
      ${magenta}alpha$reset
      ${magenta}beta$reset
      ${magenta}charlie$reset
  ${blue}opt3$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
