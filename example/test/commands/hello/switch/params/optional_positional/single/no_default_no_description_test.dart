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
              script: echo "Option 2"
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

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "Option 2"', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stdout, equals('Option 2\n'));
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
    optional:
      ${magenta}name$reset
  ${blue}opt2$reset
  ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
