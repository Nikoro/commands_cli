import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('d (preserved command)', () {
    test('executes dart commands', () async {
      final result = await Process.run('d', ['--version']);
      expect(result.stdout, contains('Dart SDK version'));
    });

    test('passes through arguments correctly', () async {
      final result = await Process.run('d', ['--version'], runInShell: true);
      expect(result.exitCode, equals(0));
    });

    test('-h passes through to dart help', () async {
      final result = await Process.run('d', ['-h']);
      expect(result.stdout, contains('Usage: dart'));
    });
  });
}
