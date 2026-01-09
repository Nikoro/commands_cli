import 'dart:io';

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
            required:  
              - beta
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints error when required param is not specified', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stderr, equals('❌ Missing required positional param: $bold${red}beta$reset\n'));
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

      test('prints error when no param is specified including required one', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}beta$reset\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}beta$reset
  optional:
    ${magenta}alpha (-a, --alpha)$reset
'''));
        });
      }
    },
  );
}
