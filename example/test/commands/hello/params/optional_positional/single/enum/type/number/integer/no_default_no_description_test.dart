import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['integer', 'int']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name:
                type: $type
                values: [1, -3]
    ''',
      () {
        for (int value in [1, -3]) {
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
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
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
💡 Must be one of: $bold${green}1$reset, $bold${green}-3$reset
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
    ${magenta}name$reset ${gray}[integer]$reset
    ${bold}values$reset: 1, -3
'''));
          });
        }
      },
    );

    for (final invalid in [
      (value: true, type: 'boolean'),
      (value: 'text', type: 'string'),
      (value: "text", type: 'string'),
      (value: '"2"', type: 'string'),
      (value: '\"2\"', type: 'string'),
      (value: '\"2\"', type: 'string'),
      (value: '\"true\"', type: 'string'),
      (value: '"true"', type: 'string'),
      (value: '\'false\'', type: 'string'),
      (value: "'false'", type: 'string'),
    ]) {
      integrationTests(
        '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name:
                type: $type
                values: [1, -3, ${invalid.value}]
    ''',
        () {
          for (int value in [1, -3]) {
            test('prints error', () async {
              final result = await Process.run('hello', ['$value']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          test('prints error', () async {
            final result = await Process.run('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await Process.run('hello', ['2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          test('prints error', () async {
            final result = await Process.run('hello', ['1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
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
            test('prints error', () async {
              final result = await Process.run('hello', [value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects an ${gray}[integer]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }
  }
}
