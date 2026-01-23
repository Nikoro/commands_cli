import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: ## Description of parameter name
                type: string
    ''',
    () {
      for (Object value in [1.5, 2, true, 'World']) {
        test('prints "Hello $value', () async {
          final result = await Process.run('hello', ['$value']);
          expect(result.stdout, equals('Hello $value\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello \n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name$reset ${gray}[string] Description of parameter name$reset
'''));
        });
      }
    },
  );
}
