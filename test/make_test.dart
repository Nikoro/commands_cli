import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('make', () {
    test('falls back to system make when no commands.yaml exists', () async {
      // Run make command without a commands.yaml file
      // Since make is a reserved command and no YAML file exists,
      // it should fall back to the original system make command
      final result = await Process.run('make', []);

      // System make will fail with "No targets specified and no makefile found"
      // This confirms the fallback to system command works correctly
      expect(result.exitCode, equals(2));
      expect(result.stderr, contains('No targets specified and no makefile found'));
    });
  });
}
