import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "This should not work"
          params:
            optional:
              - name: '-n, --name'
                type: boole
    ''',
    () {
      for (String arg in ['', '-n', '--name', '-h', '--help']) {
        test('prints error', () async {
          final result = await Process.run('hello', [arg]);
          expect(result.stderr, equals('''
❌ Invalid type "boole" for parameter $bold${red}name$reset
💡 Must be one of: $bold${green}boolean$reset, $bold${green}string$reset, $bold${green}number$reset, $bold${green}integer$reset, $bold${green}double$reset
'''));
        });
      }
    },
  );
}
