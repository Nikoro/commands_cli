import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name:
                type: double
                values: [2.0, -4.7]
    ''',
    () {
      for (double value in [2.0, -4.7]) {
        test('prints "Hello $value', () async {
          final result = await Process.run('hello', ['$value']);
          expect(result.stdout, equals('Hello $value\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints error when value is boolean', () async {
        final result = await Process.run('hello', ['true']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "true"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
'''));
      });

      for (String value in [
        'text',
        "text",
        '"1"',
        '\"1\"',
        '\'1.5\'',
        "'1.5'",
        '\"true\"',
        '"true"',
        '\'false\'',
        "'false'"
      ]) {
        test('prints error when value is string ($value)', () async {
          final result = await Process.run('hello', [value]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "$value"
💡 Must be one of: $bold${green}2.0$reset, $bold${green}-4.7$reset
'''));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}name$reset ${gray}[double]$reset
    ${bold}values$reset: 2.0, -4.7
'''));
        });
      }
    },
  );
}
