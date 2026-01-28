import 'package:test/test.dart';

import '../../../integration_tests.dart';

/// Smoke tests to verify type aliases are accepted.
/// Full parameter testing is done with the primary type names
/// ('boolean', 'number', 'integer') in the type-specific test files.
void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: bool
    ''',
    (runCommand) {
      test('bool alias: prints "Hello true"', () async {
        final result = await runCommand('hello', ['--name', 'true']);
        expect(result.stdout, equals('Hello true\n'));
      });

      test('bool alias: prints "Hello false"', () async {
        final result = await runCommand('hello', ['--name', 'false']);
        expect(result.stdout, equals('Hello false\n'));
      });
    },
  );

  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: num
    ''',
    (runCommand) {
      test('num alias: prints "Hello 42"', () async {
        final result = await runCommand('hello', ['--name', '42']);
        expect(result.stdout, equals('Hello 42\n'));
      });

      test('num alias: prints "Hello 3.14"', () async {
        final result = await runCommand('hello', ['--name', '3.14']);
        expect(result.stdout, equals('Hello 3.14\n'));
      });
    },
  );

  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name'
                type: int
    ''',
    (runCommand) {
      test('int alias: prints "Hello 42"', () async {
        final result = await runCommand('hello', ['--name', '42']);
        expect(result.stdout, equals('Hello 42\n'));
      });

      test('int alias: prints "Hello -7"', () async {
        final result = await runCommand('hello', ['--name', '-7']);
        expect(result.stdout, equals('Hello -7\n'));
      });
    },
  );
}
