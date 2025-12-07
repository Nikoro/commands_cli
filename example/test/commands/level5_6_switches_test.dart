import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  // Level 5: Switch with defaults
  group('sw1_default_no_comment', () {
    test('runs default option without arguments', () async {
      final result = await Process.run('sw1_default_no_comment', []);
      expect(result.stdout, equals('Option 1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 explicitly', () async {
      final result = await Process.run('sw1_default_no_comment', ['opt1']);
      expect(result.stdout, equals('Option 1\n'));
    });

    test('runs opt2', () async {
      final result = await Process.run('sw1_default_no_comment', ['opt2']);
      expect(result.stdout, equals('Option 2\n'));
    });

    test('runs opt3', () async {
      final result = await Process.run('sw1_default_no_comment', ['opt3']);
      expect(result.stdout, equals('Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw1_default_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw1_default_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  ${blue}opt2$reset\n'
            '  ${blue}opt3$reset\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw2_default_partial_comment', () {
    test('runs default option (opt2)', () async {
      final result = await Process.run('sw2_default_partial_comment', []);
      expect(result.stdout, equals('Option 2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1', () async {
      final result = await Process.run('sw2_default_partial_comment', ['opt1']);
      expect(result.stdout, equals('Option 1\n'));
    });

    test('runs opt2 explicitly', () async {
      final result = await Process.run('sw2_default_partial_comment', ['opt2']);
      expect(result.stdout, equals('Option 2\n'));
    });

    test('runs opt3', () async {
      final result = await Process.run('sw2_default_partial_comment', ['opt3']);
      expect(result.stdout, equals('Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw2_default_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw2_default_partial_comment$reset: ${gray}Switch with default and partial comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  ${blue}opt2$reset\n'
            '  ${blue}opt3$reset: ${gray}Third option$reset\n'
            '  ${bold}default$reset: ${blue}opt2$reset\n',
          ),
        );
      });
    }
  });

  group('sw3_default_all_comment', () {
    test('runs default option (opt3)', () async {
      final result = await Process.run('sw3_default_all_comment', []);
      expect(result.stdout, equals('Option 3\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1', () async {
      final result = await Process.run('sw3_default_all_comment', ['opt1']);
      expect(result.stdout, equals('Option 1\n'));
    });

    test('runs opt2', () async {
      final result = await Process.run('sw3_default_all_comment', ['opt2']);
      expect(result.stdout, equals('Option 2\n'));
    });

    test('runs opt3 explicitly', () async {
      final result = await Process.run('sw3_default_all_comment', ['opt3']);
      expect(result.stdout, equals('Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw3_default_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw3_default_all_comment$reset: ${gray}Switch with default all options commented$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  ${blue}opt2$reset: ${gray}Second option$reset\n'
            '  ${blue}opt3$reset: ${gray}Third option$reset\n'
            '  ${bold}default$reset: ${blue}opt3$reset\n',
          ),
        );
      });
    }
  });

  // Level 6: Switch without defaults (interactive menu)
  group('sw4_menu_no_comment', () {
    test('requires option (no default)', () async {
      final result = await Process.run('sw4_menu_no_comment', []);
      // Without option, should show menu or error
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1', () async {
      final result = await Process.run('sw4_menu_no_comment', ['opt1']);
      expect(result.stdout, equals('Menu Option 1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2', () async {
      final result = await Process.run('sw4_menu_no_comment', ['opt2']);
      expect(result.stdout, equals('Menu Option 2\n'));
    });

    test('runs opt3', () async {
      final result = await Process.run('sw4_menu_no_comment', ['opt3']);
      expect(result.stdout, equals('Menu Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw4_menu_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw4_menu_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  ${blue}opt2$reset\n'
            '  ${blue}opt3$reset\n',
          ),
        );
      });
    }
  });

  group('sw5_menu_partial_comment', () {
    test('requires option (no default)', () async {
      final result = await Process.run('sw5_menu_partial_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1', () async {
      final result = await Process.run('sw5_menu_partial_comment', ['opt1']);
      expect(result.stdout, equals('Menu Option 1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2', () async {
      final result = await Process.run('sw5_menu_partial_comment', ['opt2']);
      expect(result.stdout, equals('Menu Option 2\n'));
    });

    test('runs opt3', () async {
      final result = await Process.run('sw5_menu_partial_comment', ['opt3']);
      expect(result.stdout, equals('Menu Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw5_menu_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw5_menu_partial_comment$reset: ${gray}Interactive menu with partial comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First menu option$reset\n'
            '  ${blue}opt2$reset\n'
            '  ${blue}opt3$reset: ${gray}Third menu option$reset\n',
          ),
        );
      });
    }
  });

  group('sw6_menu_all_comment', () {
    test('requires option (no default)', () async {
      final result = await Process.run('sw6_menu_all_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1', () async {
      final result = await Process.run('sw6_menu_all_comment', ['opt1']);
      expect(result.stdout, equals('Menu Option 1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2', () async {
      final result = await Process.run('sw6_menu_all_comment', ['opt2']);
      expect(result.stdout, equals('Menu Option 2\n'));
    });

    test('runs opt3', () async {
      final result = await Process.run('sw6_menu_all_comment', ['opt3']);
      expect(result.stdout, equals('Menu Option 3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw6_menu_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw6_menu_all_comment$reset: ${gray}Interactive menu all options commented$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First menu option$reset\n'
            '  ${blue}opt2$reset: ${gray}Second menu option$reset\n'
            '  ${blue}opt3$reset: ${gray}Third menu option$reset\n',
          ),
        );
      });
    }
  });
}
