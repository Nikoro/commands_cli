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
                optional:
                  - name: '-n, --name, nm' ## Description of parameter name
            - opt2: ## Description of option 2
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                optional:
                  - alpha: '-a, --alpha' ## Description of parameter alpha
                  - beta: '--beta, -b' ## Description of parameter beta
                  - charlie: '-c, --charlie' ## Description of parameter charlie
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: ## Description of custom option
              script: echo "Custom"
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', ['opt1', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: , C: "', () async {
          final result = await Process.run('hello', ['opt2', alpha, 'x']);
          expect(result.stdout, equals('A: x, B: , C: \n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints "A: , B: y, C: "', () async {
            final result = await Process.run('hello', ['opt2', beta, 'y']);
            expect(result.stdout, equals('A: , B: y, C: \n'));
          });
          test('prints "A: x, B: y, C: "', () async {
            final result = await Process.run('hello', ['opt2', alpha, 'x', beta, 'y']);
            expect(result.stdout, equals('A: x, B: y, C: \n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: , B: , C: z"', () async {
              final result = await Process.run('hello', ['opt2', charlie, 'z']);
              expect(result.stdout, equals('A: , B: , C: z\n'));
            });
            test('prints "A: x, B: , C: z"', () async {
              final result = await Process.run('hello', ['opt2', alpha, 'x', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: , C: z\n'));
            });
            test('prints "A: , B: y, C: z"', () async {
              final result = await Process.run('hello', ['opt2', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: , B: y, C: z\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await Process.run('hello', ['opt2', alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stdout, equals('A: , B: , C: \n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: , B: , C: " when no value for optional param [$alpha] is specified', () async {
          final result = await Process.run('hello', ['opt2', alpha]);
          expect(result.stdout, equals('A: , B: , C: \n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints "A: , B: , C: " when no value for optional param [$beta] is specified', () async {
            final result = await Process.run('hello', ['opt2', beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$beta] is specified', () async {
            final result = await Process.run('hello', ['opt2', alpha, beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: , B: , C: " when no value for optional param [$charlie] is specified', () async {
              final result = await Process.run('hello', ['opt2', charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', ['opt2', alpha, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', ['opt2', beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test(
                'prints "A: , B: , C: " when no value for optional params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', ['opt2', alpha, beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });
          }
        }
      }

      test('prints "Option 3"', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
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
  ${blue}opt1$reset: ${gray}Description of option 1$reset
  params:
    optional:
      ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
  ${blue}opt2$reset: ${gray}Description of option 2$reset
  params:
    optional:
      ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
      ${magenta}beta (--beta, -b)$reset ${gray}Description of parameter beta$reset
      ${magenta}charlie (-c, --charlie)$reset ${gray}Description of parameter charlie$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset: ${gray}Description of custom option$reset
'''));
        });
      }
    },
  );
}
