import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name, nm'
                default: Bob
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello Bob\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints with default value when no value for optional param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('Hello Bob\n'));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name, nm)$reset
    ${bold}default$reset: "Bob"
'''));
        });
      }
    },
  );
}
