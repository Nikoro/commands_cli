import 'dart:io';

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
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                required:
                  - alpha: '-a, --alpha'
                  - beta: '--beta, -b'
                  - charlie: '-c, --charlie' ## Description of parameter charlie
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default:
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

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints error when required params is not specified', () async {
          final result = await Process.run('hello', ['opt2', alpha, 'x']);
          expect(result.stderr,
              equals('❌ Missing required named params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints error when required param is not specified', () async {
            final result = await Process.run('hello', ['opt2', beta, 'y']);
            expect(result.stderr,
                equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
          });
          test('prints error when required param is not specified', () async {
            final result = await Process.run('hello', ['opt2', alpha, 'x', beta, 'y']);
            expect(result.stderr, equals('❌ Missing required named param: $bold${red}charlie$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', ['opt2', charlie, 'z']);
              expect(result.stderr,
                  equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', ['opt2', alpha, 'x', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', ['opt2', beta, 'y', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await Process.run('hello', ['opt2', alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(
            result.stderr,
            equals(
                '❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints error when no value for required param [$alpha] is specified', () async {
          final result = await Process.run('hello', ['opt2', alpha]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}alpha$reset\n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints error when no value for required param [$beta] is specified', () async {
            final result = await Process.run('hello', ['opt2', beta]);
            expect(result.stderr, equals('❌ Missing value for param: $bold${red}beta$reset\n'));
          });

          test('prints error when no value for required params [$alpha] and [$beta] is specified', () async {
            final result = await Process.run('hello', ['opt2', alpha, beta]);
            expect(
                result.stderr, equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when no value for required param [$charlie] is specified', () async {
              final result = await Process.run('hello', ['opt2', charlie]);
              expect(result.stderr, equals('❌ Missing value for param: $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha] and [$charlie] is specified', () async {
              final result = await Process.run('hello', ['opt2', alpha, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$beta] and [$charlie] is specified', () async {
              final result = await Process.run('hello', ['opt2', beta, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', ['opt2', alpha, beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
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
  ${blue}opt1$reset
  params:
    required:
      ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
  ${blue}opt2$reset
  params:
    required:
      ${magenta}alpha (-a, --alpha)$reset
      ${magenta}beta (--beta, -b)$reset
      ${magenta}charlie (-c, --charlie)$reset ${gray}Description of parameter charlie$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
