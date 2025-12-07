import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('s1_no_comment', () {
    test('runs correctly', () async {
      final result = await Process.run('s1_no_comment', []);
      expect(result.stdout, equals('Simple script without comment\n'));
    });

    test('exits with code 0', () async {
      final result = await Process.run('s1_no_comment', []);
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('s1_no_comment', [flag]);
        expect(result.stdout, equals('${blue}s1_no_comment$reset\n'));
      });
    }
  });

  group('s2_with_comment', () {
    test('runs correctly', () async {
      final result = await Process.run('s2_with_comment', []);
      expect(result.stdout, equals('Simple script with comment\n'));
    });

    test('exits with code 0', () async {
      final result = await Process.run('s2_with_comment', []);
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('s2_with_comment', [flag]);
        expect(result.stdout, equals('${blue}s2_with_comment$reset: ${gray}Simple script with description$reset\n'));
      });
    }
  });
}
