import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - opt1: '-o1, one'
              script: echo "Option 1"
            - opt2: -o2, two
              script: echo "Option 2"
            - opt3: "-o3, three"
              script: echo "Option 3"
    ''',
    () {
      for (String option in ['opt1', '-o1', 'one']) {
        test('prints "Option 1"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 1\n'));
        });
      }

      for (String option in ['opt2', '-o2', 'two']) {
        test('prints "Option 2"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 2\n'));
        });
      }
      for (String option in ['opt3', '-o3', 'three']) {
        test('prints "Option 3"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 3\n'));
        });
      }
      test('shows interactive picker when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. opt1 ✓$reset ${gray}or: [-o1, one]$reset
    2. opt2   ${gray}or: [-o2, two]$reset
    3. opt3   ${gray}or: [-o3, three]$reset

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
  ${blue}opt1$reset ${gray}or: [-o1, one]$reset
  ${blue}opt2$reset ${gray}or: [-o2, two]$reset
  ${blue}opt3$reset ${gray}or: [-o3, three]$reset
'''));
        });
      }
    },
  );
}
