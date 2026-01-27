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
                required:
                  - name: '-n, --name, nm'
            - opt2:
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                required:
                  - alpha: '-a, --alpha'
                  - beta: '--beta, -b'
                  - charlie: '-c, --charlie'
            - opt3:
              script: echo "Option 3"
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

      for (String alpha in ['-a', '--alpha']) {
        test('prints error when required params is not specified', () async {
          final result = await runCommand('hello', ['opt2', alpha, 'x']);
          expect(result.stderr,
              equals('❌ Missing required named params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints error when required param is not specified', () async {
            final result = await runCommand('hello', ['opt2', beta, 'y']);
            expect(result.stderr,
                equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
          });
          test('prints error when required param is not specified', () async {
            final result = await runCommand('hello', ['opt2', alpha, 'x', beta, 'y']);
            expect(result.stderr, equals('❌ Missing required named param: $bold${red}charlie$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when required param is not specified', () async {
              final result = await runCommand('hello', ['opt2', charlie, 'z']);
              expect(result.stderr,
                  equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await runCommand('hello', ['opt2', alpha, 'x', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await runCommand('hello', ['opt2', beta, 'y', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await runCommand('hello', ['opt2', alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await runCommand('hello', ['opt2']);
        expect(
            result.stderr,
            equals(
                '❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints error when no value for required param [$alpha] is specified', () async {
          final result = await runCommand('hello', ['opt2', alpha]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}alpha$reset\n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints error when no value for required param [$beta] is specified', () async {
            final result = await runCommand('hello', ['opt2', beta]);
            expect(result.stderr, equals('❌ Missing value for param: $bold${red}beta$reset\n'));
          });

          test('prints error when no value for required params [$alpha] and [$beta] is specified', () async {
            final result = await runCommand('hello', ['opt2', alpha, beta]);
            expect(
                result.stderr, equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when no value for required param [$charlie] is specified', () async {
              final result = await runCommand('hello', ['opt2', charlie]);
              expect(result.stderr, equals('❌ Missing value for param: $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha] and [$charlie] is specified', () async {
              final result = await runCommand('hello', ['opt2', alpha, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$beta] and [$charlie] is specified', () async {
              final result = await runCommand('hello', ['opt2', beta, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await runCommand('hello', ['opt2', alpha, beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
            });
          }
        }
      }

      test('prints "Option 3"', () async {
        final result = await runCommand('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('shows interactive picker when no option is specified', () async {
        final result = await runCommand('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. opt1 ✓$reset
    2. opt2  
    3. opt3  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}opt1$reset
  params:
    required:
      ${magenta}name (-n, --name, nm)$reset
  ${blue}opt2$reset
  params:
    required:
      ${magenta}alpha (-a, --alpha)$reset
      ${magenta}beta (--beta, -b)$reset
      ${magenta}charlie (-c, --charlie)$reset
  ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
