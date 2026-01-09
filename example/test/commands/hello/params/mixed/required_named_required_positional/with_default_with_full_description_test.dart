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
                default: "A1"
              - beta: ## Description of parameter beta
                default: "B1"
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: B1"', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stdout, equals('A: x, B: B1\n'));
        });

        test('prints "A: x, B: y"', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y']);
          expect(result.stdout, equals('A: x, B: y\n'));
        });
      }

      test('prints "A: A1, B: y"', () async {
        final result = await Process.run('hello', ['y']);
        expect(result.stdout, equals('A: A1, B: y\n'));
      });

      test('prints "A: A1, B: B1" when no param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: A1, B: B1\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
    ${bold}default$reset: "A1"
    ${magenta}beta$reset ${gray}Description of parameter beta$reset
    ${bold}default$reset: "B1"
'''));
        });
      }
    },
  );
}
