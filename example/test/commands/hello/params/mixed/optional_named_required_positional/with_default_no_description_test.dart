import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: |
            echo "A: {alpha}, B: {beta}"
          params:
            optional:
              - alpha: '-a, --alpha'
                default: "A1"
            required:  
              - beta:
                default: "B1"
    ''',
    (runCommand) {
      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: B1"', () async {
          final result = await runCommand('hello', [alpha, 'x']);
          expect(result.stdout, equals('A: x, B: B1\n'));
        });

        test('prints "A: x, B: y"', () async {
          final result = await runCommand('hello', [alpha, 'x', 'y']);
          expect(result.stdout, equals('A: x, B: y\n'));
        });
      }

      test('prints "A: A1, B: y"', () async {
        final result = await runCommand('hello', ['y']);
        expect(result.stdout, equals('A: A1, B: y\n'));
      });

      test('prints "A: A1, B: B1" when no param is specified', () async {
        final result = await runCommand('hello', []);
        expect(result.stdout, equals('A: A1, B: B1\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}beta$reset
    ${bold}default$reset: $bold${orange}B1$reset
  optional:
    ${magenta}alpha (-a, --alpha)$reset
    ${bold}default$reset: $bold${orange}A1$reset
'''));
        });
      }
    },
  );
}
