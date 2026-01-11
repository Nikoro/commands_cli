import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';
import '../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - opt1:
              script: echo "Hello {name}"
              params:
                required:
                  - name: '-n, --name, nm'
                    values: [Alpha, Bravo, Charlie]
            - opt2:
              script: echo "Option 2"
            - opt3:
              script: echo "Option 3"
            - default:
              script: echo "Custom"
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', ['opt1', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('shows interactive picker when no required param is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(
          result.stdout,
          equals('''

Select value for ${blue}name$reset:

    ${green}1. Alpha   ✓$reset
    2. Bravo    
    3. Charlie  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no value for required param is specified', () async {
          final result = await Process.run('hello', ['opt1', flag]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid value for required param is specified', () async {
          final result = await Process.run('hello', ['opt1', flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

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
        expect(result.stdout, equals('Custom\n'));
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
      ${magenta}name (-n, --name, nm)$reset
      ${bold}values$reset: Alpha, Bravo, Charlie
  ${blue}opt2$reset
  ${blue}opt3$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
