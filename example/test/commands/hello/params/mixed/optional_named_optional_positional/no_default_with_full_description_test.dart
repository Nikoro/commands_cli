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
            optional:
              - alpha: '-a, --alpha' ## Description of parameter alpha
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

      test('prints "A: , B: y"', () async {
        final result = await Process.run('hello', ['y']);
        expect(result.stdout, equals('A: , B: y\n'));
      });

      test('prints "A: , B: " when no param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: , B: \n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
    ${magenta}beta$reset ${gray}Description of parameter beta$reset
'''));
        });
      }
    },
  );
}
