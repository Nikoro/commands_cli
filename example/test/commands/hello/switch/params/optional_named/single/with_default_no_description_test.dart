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
                  - name: '-n, --name, nm'
            - opt2:
              script: echo "Option 2"
            - opt3:
              script: echo "Option 3"
            - default: opt3
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', ['opt1', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
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
      ${magenta}name (-n, --name, nm)$reset
  ${blue}opt2$reset
  ${blue}opt3$reset
  ${bold}default$reset: ${blue}opt3$reset
'''));
        });
      }
    },
  );
}
