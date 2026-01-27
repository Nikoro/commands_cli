import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - level1a:
              switch:
                - level2a:
                  script: echo "Hello {name}"
                  params:
                    required:
                      - name: '-n, --name, nm'
                        values: [Alpha, Bravo, Charlie]
                - level2b:
                  script: echo "Level 1a 2b"
                - level2c:
                  script: echo "Level 1a 2c"
            - level1b:
              script: echo "Level 1b"
            - level1c:
              script: echo "Level 1c"
    ''',
    (runCommand) {
      test('shows interactive picker when option with nested switch is not specified', () async {
        final result = await runCommand('hello', ['level1a']);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello level1a$reset:

    ${green}1. level2a ✓$reset
    2. level2b  
    3. level2c  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints "Hello $param"', () async {
            final result = await runCommand('hello', ['level1a', 'level2a', flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('shows interactive picker when no required param is specified', () async {
        final result = await runCommand('hello', ['level1a', 'level2a']);
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
          final result = await runCommand('hello', ['level1a', 'level2a', flag]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}name$reset\n'));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid value for required param is specified', () async {
          final result = await runCommand('hello', ['level1a', 'level2a', flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

      test('prints "Level 1a 2b"', () async {
        final result = await runCommand('hello', ['level1a', 'level2b']);
        expect(result.stdout, equals('Level 1a 2b\n'));
      });

      test('prints "Level 1a 2c"', () async {
        final result = await runCommand('hello', ['level1a', 'level2c']);
        expect(result.stdout, equals('Level 1a 2c\n'));
      });

      test('prints "Level 1b"', () async {
        final result = await runCommand('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await runCommand('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('shows interactive picker when no option is specified', () async {
        final result = await runCommand('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. level1a ✓$reset
    2. level1b  
    3. level1c  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}level1a$reset
  options:
    ${blue}level2a$reset
    params:
      required:
        ${magenta}name (-n, --name, nm)$reset
        ${bold}values$reset: Alpha, Bravo, Charlie
    ${blue}level2b$reset
    ${blue}level2c$reset
  ${blue}level1b$reset
  ${blue}level1c$reset
'''));
        });
      }
    },
  );
}
