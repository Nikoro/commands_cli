import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha:
              - beta:
              - charlie:
    ''',
    (runCommand) {
      test('prints error when no required param is specified', () async {
        final result = await runCommand('hello', []);
        expect(
            result.stderr,
            equals(
                '❌ Missing required positional params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      test('prints error when required param is not specified', () async {
        final result = await runCommand('hello', ['x']);
        expect(result.stderr,
            equals('❌ Missing required positional params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      test('prints error when required param is not specified', () async {
        final result = await runCommand('hello', ['x', 'y']);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}charlie$reset\n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await runCommand('hello', ['x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}alpha$reset
    ${magenta}beta$reset
    ${magenta}charlie$reset
'''));
        });
      }
    },
  );
}
