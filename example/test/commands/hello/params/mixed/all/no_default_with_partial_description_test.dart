import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}, D: {delta}"
          params:
            required:
              - alpha: '-a, --alpha' ## Description of parameter alpha
              - beta
            optional:
              - charlie: '-c, --charlie'
              - delta: ## Description of parameter delta
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints error when required param is not specified', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stderr, equals('❌ Missing required positional param: $bold${red}beta$reset\n'));
        });

        test('prints "A: x, B: y, C: , D: "', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y']);
          expect(result.stdout, equals('A: x, B: y, C: , D: \n'));
        });

        test('prints "A: x, B: y, C: , D: z"', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y', 'z']);
          expect(result.stdout, equals('A: x, B: y, C: , D: z\n'));
        });

        for (String charlie in ['-c', '--charlie']) {
          test('prints "A: x, B: y, C: z, D: "', () async {
            final result = await Process.run('hello', [alpha, 'x', 'y', charlie, 'z']);
            expect(result.stdout, equals('A: x, B: y, C: z, D: \n'));
          });

          test('prints "A: x, B: y, C: z, D: a"', () async {
            final result = await Process.run('hello', [alpha, 'x', 'y', charlie, 'z', 'a']);
            expect(result.stdout, equals('A: x, B: y, C: z, D: a\n'));
          });
        }
      }

      test('prints error when required param is not specified', () async {
        final result = await Process.run('hello', ['y']);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
      });

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}beta$reset\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
    ${magenta}beta$reset
  optional:
    ${magenta}charlie (-c, --charlie)$reset
    ${magenta}delta$reset ${gray}Description of parameter delta$reset
'''));
        });
      }
    },
  );
}
