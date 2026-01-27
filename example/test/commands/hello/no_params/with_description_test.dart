import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello World"
    ''',
    (runCommand) {
      test('prints "Hello World"', () async {
        final result = await runCommand('hello', []);
        expect(result.stdout, equals('Hello World\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await runCommand('hello', [flag]);
          expect(result.stdout, equals('${blue}hello$reset: ${gray}Description of command hello$reset\n'));
        });
      }
    },
  );
}
