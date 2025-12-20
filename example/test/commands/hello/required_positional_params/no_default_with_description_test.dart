import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
    ''',
    () {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name$reset ${gray}Description of parameter name$reset
'''));
        });
      }
    },
  );

  /// Those tests fail. After parameter name there is no ":" and after is description ##. It breaks and it shouldn't
  ///
  ///
//   integrationTests(
//     '''
//         hello: ## Description of command hello
//           script: echo "Hello {name}"
//           params:
//             required:
//               - name ## Description of parameter name
//     ''',
//     () {
//       for (Object param in ['World', 1, 2.2, true]) {
//         test('prints "Hello $param"', () async {
//           final result = await Process.run('hello', ['$param']);
//           expect(result.stdout, equals('Hello $param\n'));
//         });
//       }

//       test('prints error when no required param is specified', () async {
//         final result = await Process.run('hello', []);
//         expect(result.stderr, equals('❌ Missing required positional param: $bold${red}name$reset\n'));
//       });

//       for (String flag in ['-h', '--help']) {
//         test('$flag prints help', () async {
//           final result = await Process.run('hello', [flag]);
//           expect(result.stdout, equals('''
// ${blue}hello$reset: ${gray}Description of command hello$reset
// params:
//   required:
//     ${magenta}name$reset ${gray}Description of parameter name$reset
// '''));
//         });
//       }
//     },
//   );
}
