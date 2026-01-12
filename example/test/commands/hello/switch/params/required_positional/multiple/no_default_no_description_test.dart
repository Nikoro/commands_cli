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
                required:
                  - name
            - opt2:
              script: |
                echo "A: {alpha}, B: {beta}, C: {charlie}"
              params:
                required:
                  - alpha
                  - beta
                  - charlie
            - opt3:
              script: echo "Option 3"
    ''',
    () {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['opt1', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
      });

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(
            result.stderr,
            equals(
                '❌ Missing required positional params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      test('prints error when required param is not specified', () async {
        final result = await Process.run('hello', ['opt2', 'x']);
        expect(result.stderr,
            equals('❌ Missing required positional params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
      });

      test('prints error when required param is not specified', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y']);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}charlie$reset\n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await Process.run('hello', ['opt2', 'x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      test('prints "Option 3"', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('shows interactive picker when no option is specified', () async {
        final result = await Process.run('hello', []);
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
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}opt1$reset
  params:
    required:
      ${magenta}name$reset
  ${blue}opt2$reset
  params:
    required:
      ${magenta}alpha$reset
      ${magenta}beta$reset
      ${magenta}charlie$reset
  ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
