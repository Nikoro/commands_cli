import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "This should not work"
          switch:
            - opt1:
              script: echo "This should not work"
            - opt2:
              script: echo "This should not work"
    ''',
    () {
      for (String arg in ['', 'opt1', 'opt2', '-h', '--help']) {
        test('prints error', () async {
          final result = await Process.run('hello', [arg]);
          expect(result.stderr,
              equals('❌ Cannot use both $bold${red}script$reset and $bold${red}switch$reset at the same time\n'));
        });
      }
    },
  );
}
