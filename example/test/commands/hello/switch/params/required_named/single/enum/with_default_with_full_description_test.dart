import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1: ## Description of option 1
              script: echo "Hello {name}"
              params:
                required:
                  - name: '-n, --name, nm' ## Description of parameter name
                    values: [Alpha, Bravo, Charlie]
                    default: Charlie
            - opt2: ## Description of option 2
              script: echo "Option 2"
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: opt3
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

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stdout, equals('Hello Charlie\n'));
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
        expect(result.stdout, equals('Option 3\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset: ${gray}Description of option 1$reset
  params:
    required:
      ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
      ${bold}values$reset: Alpha, Bravo, Charlie
      ${bold}default$reset: "Charlie"
  ${blue}opt2$reset: ${gray}Description of option 2$reset
  ${blue}opt3$reset: ${gray}Description of option 3$reset
  ${bold}default$reset: ${blue}opt3$reset
'''));
        });
      }
    },
  );

  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1: ## Description of option 1
              script: echo "Hello {name}"
              params:
                required:
                  - name: '-n, --name, nm' ## Description of parameter name
                    values: [Alpha, Bravo, Charlie]
                    default: Delta
            - opt2: ## Description of option 2
              script: echo "Option 2"
            - opt3: ## Description of option 3
              script: echo "Option 3"
            - default: opt3
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints error when invalid default value is specified', () async {
            final result = await Process.run('hello', ['opt1', flag, '$param']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
          });
        }
      }

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', ['opt1', flag]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', ['opt1', flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-h', '--help']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }
    },
  );
}
