import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: |
            echo "A: {alpha}, B: {beta}"
          params:
            required:
              - alpha: '-a, --alpha' ## Description of parameter alpha
            optional:
              - beta: ## Description of parameter beta
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: "', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stdout, equals('A: x, B: \n'));
        });

        test('prints "A: x, B: y"', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y']);
          expect(result.stdout, equals('A: x, B: y\n'));
        });
      }

      test('prints error when required param is not specified', () async {
        final result = await Process.run('hello', ['y']);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
      });

      test('prints error when no param is specified including required one', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
  optional:
    ${magenta}beta$reset ${gray}Description of parameter beta$reset
'''));
        });
      }
    },
  );
}
