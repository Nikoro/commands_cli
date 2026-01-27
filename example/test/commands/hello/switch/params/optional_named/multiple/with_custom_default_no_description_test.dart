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
                  - name: '-n, --name, nm'
            - opt2:
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                optional:
                  - alpha: '-a, --alpha'
                  - beta: '--beta, -b'
                  - charlie: '-c, --charlie'
            - opt3:
              script: echo "Option 3"
            - default:
              script: echo "Custom"
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

      test('prints "Hello " when no optional param is specified', () async {
        final result = await runCommand('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: , C: "', () async {
          final result = await runCommand('hello', ['opt2', alpha, 'x']);
          expect(result.stdout, equals('A: x, B: , C: \n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints "A: , B: y, C: "', () async {
            final result = await runCommand('hello', ['opt2', beta, 'y']);
            expect(result.stdout, equals('A: , B: y, C: \n'));
          });
          test('prints "A: x, B: y, C: "', () async {
            final result = await runCommand('hello', ['opt2', alpha, 'x', beta, 'y']);
            expect(result.stdout, equals('A: x, B: y, C: \n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: , B: , C: z"', () async {
              final result = await runCommand('hello', ['opt2', charlie, 'z']);
              expect(result.stdout, equals('A: , B: , C: z\n'));
            });
            test('prints "A: x, B: , C: z"', () async {
              final result = await runCommand('hello', ['opt2', alpha, 'x', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: , C: z\n'));
            });
            test('prints "A: , B: y, C: z"', () async {
              final result = await runCommand('hello', ['opt2', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: , B: y, C: z\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await runCommand('hello', ['opt2', alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await runCommand('hello', ['opt2']);
        expect(result.stdout, equals('A: , B: , C: \n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: , B: , C: " when no value for optional param [$alpha] is specified', () async {
          final result = await runCommand('hello', ['opt2', alpha]);
          expect(result.stdout, equals('A: , B: , C: \n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints "A: , B: , C: " when no value for optional param [$beta] is specified', () async {
            final result = await runCommand('hello', ['opt2', beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$beta] is specified', () async {
            final result = await runCommand('hello', ['opt2', alpha, beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: , B: , C: " when no value for optional param [$charlie] is specified', () async {
              final result = await runCommand('hello', ['opt2', charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$charlie] is specified',
                () async {
              final result = await runCommand('hello', ['opt2', alpha, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$beta] and [$charlie] is specified',
                () async {
              final result = await runCommand('hello', ['opt2', beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test(
                'prints "A: , B: , C: " when no value for optional params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await runCommand('hello', ['opt2', alpha, beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });
          }
        }
      }

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
      ${magenta}name (-n, --name, nm)$reset
  ${blue}opt2$reset
  params:
    optional:
      ${magenta}alpha (-a, --alpha)$reset
      ${magenta}beta (--beta, -b)$reset
      ${magenta}charlie (-c, --charlie)$reset
  ${blue}opt3$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
