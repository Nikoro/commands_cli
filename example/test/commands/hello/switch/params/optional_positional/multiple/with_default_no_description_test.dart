import 'dart:io';

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
                  - name
            - opt2:
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                optional:
                  - alpha:
                    default: "A1"
                  - beta:
                    default: "B1"
                  - charlie:
                    default: "C1"
            - opt3:
              script: echo "Option 3"
            - default: opt3
    ''',
    () {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['opt1', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "A: x, B: B1, C: C1"', () async {
        final result = await Process.run('hello', ['opt2', 'x']);
        expect(result.stdout, equals('A: x, B: B1, C: C1\n'));
      });

      test('prints "A: x, B: y, C: C1"', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y']);
        expect(result.stdout, equals('A: x, B: y, C: C1\n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      test('prints "A: A1, B: B1, C: C1" when no optional param is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
      });

      test('prints "Option 3"', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Option 3\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}opt1$reset
  params:
    optional:
      ${magenta}name$reset
  ${blue}opt2$reset
  params:
    optional:
      ${magenta}alpha$reset
      ${bold}default$reset: "A1"
      ${magenta}beta$reset
      ${bold}default$reset: "B1"
      ${magenta}charlie$reset
      ${bold}default$reset: "C1"
  ${blue}opt3$reset
  ${bold}default$reset: ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
