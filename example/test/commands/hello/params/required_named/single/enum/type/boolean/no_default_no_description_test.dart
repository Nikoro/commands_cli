import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  for (String type in ['boolean', 'bool']) {
    integrationTests(
      '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name: '-n, --name'
                type: $type
                values: [true, false]
    ''',
      () {
        for (String flag in ['-n', '--name']) {
          for (bool value in [true, false]) {
            test('prints "Hello $value', () async {
              final result = await Process.run('hello', [flag, '$value']);
              expect(result.stdout, equals('Hello $value\n'));
            });
          }
        }

      test('shows interactive picker when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(
          result.stdout,
          equals('''

Select value for ${blue}name$reset:

    ${green}0. false ✓$reset
    1. true

${gray}Use arrows to navigate, 0/f for false, 1/t for true, Enter to confirm, Esc to cancel$reset
'''),
        );
      });

        for (String flag in ['-n', '--name']) {
          test('prints "Hello true" when no value for required param is specified', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('Hello true\n'));
          });

          test('prints error when value is integer', () async {
            final result = await Process.run('hello', [flag, '2']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 2 ${gray}[integer]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
          });

          test('prints error when value is double', () async {
            final result = await Process.run('hello', [flag, '1.5']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: 1.5 ${gray}[double]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
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
              final result = await Process.run('hello', [flag, value]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: $value ${gray}[string]$reset
💡 Example: $bgGreen${black}hello $flag true$reset or $bgGreen${black}hello $flag false$reset
'''));
            });
          }
        }

        for (String flag in ['-h', '--help']) {
          test('$flag prints help', () async {
            final result = await Process.run('hello', [flag]);
            expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n, --name)$reset ${gray}[boolean]$reset
    ${bold}values$reset: true, false
'''));
          });
        }
      },
    );
  }

  for (String type in ['boolean', 'bool']) {
    for (final invalid in [
      (value: 2, type: 'integer'),
      (value: 1.5, type: 'double'),
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
            required:
              - name: '-n, --name'
                type: $type
                values: [true, false, ${invalid.value}]
    ''',
        () {
          for (String flag in ['-n', '--name']) {
            for (bool value in [true, false]) {
              test('prints error', () async {
                final result = await Process.run('hello', [flag, '$value']);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });
            }
          }

          test('prints error', () async {
            final result = await Process.run('hello', []);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
          });

          for (String flag in ['-n', '--name']) {
            test('prints error', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            test('prints error', () async {
              final result = await Process.run('hello', [flag, '2']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });

            test('prints error', () async {
              final result = await Process.run('hello', [flag, '1.5']);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
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
                final result = await Process.run('hello', [flag, value]);
                expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
              });
            }
          }

          for (String flag in ['-h', '--help']) {
            test('prints error', () async {
              final result = await Process.run('hello', [flag]);
              expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset expects a ${gray}[boolean]$reset
   Got: ${invalid.value} ${gray}[${invalid.type}]$reset in values
'''));
            });
          }
        },
      );
    }
  }
}
