import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('Error Cases - Missing Required Params', () {
    group('err_missing_named_req', () {
      test('fails without required named param', () async {
        final result = await Process.run('err_missing_named_req', []);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
      });

      test('succeeds with required named param', () async {
        final result = await Process.run('err_missing_named_req', ['-r', 'value']);
        expect(result.stdout, equals('Required: value\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with long flag variant', () async {
        final result = await Process.run('err_missing_named_req', ['--required', 'value']);
        expect(result.stdout, equals('Required: value\n'));
        expect(result.exitCode, equals(0));
      });
    });

    group('err_missing_positional_req', () {
      test('fails without required positional param', () async {
        final result = await Process.run('err_missing_positional_req', []);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
      });

      test('succeeds with positional argument', () async {
        final result = await Process.run('err_missing_positional_req', ['value']);
        expect(result.stdout, equals('Required: value\n'));
        expect(result.exitCode, equals(0));
      });
    });

    group('err_missing_multiple_req', () {
      test('fails without any params', () async {
        final result = await Process.run('err_missing_multiple_req', []);
        expect(result.exitCode, isNot(0));
        expect(
          result.stderr,
          equals('❌ Missing required named params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n'),
        );
      });

      test('fails with only one param', () async {
        final result = await Process.run('err_missing_multiple_req', ['-x', 'X1']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named params: ${bold}${red}y$reset, ${bold}${red}z$reset\n'));
      });

      test('fails with only two params', () async {
        final result = await Process.run('err_missing_multiple_req', ['-x', 'X1', '-y', 'Y1']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}z$reset\n'));
      });

      test('succeeds with all three required params', () async {
        final result = await Process.run('err_missing_multiple_req', ['-x', 'X1', '-y', 'Y1', '-z', 'Z1']);
        expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
        expect(result.exitCode, equals(0));
      });
    });

    group('err_hybrid_missing', () {
      test('fails without any params', () async {
        final result = await Process.run('err_hybrid_missing', []);
        expect(result.exitCode, isNot(0));
        // Should report both named and positional missing
        expect(result.stderr, contains('Missing required'));
      });

      test('fails with only named param', () async {
        final result = await Process.run('err_hybrid_missing', ['-n', 'named_value']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Missing required'));
      });

      test('fails with only positional param', () async {
        final result = await Process.run('err_hybrid_missing', ['pos_value']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Missing required'));
      });

      test('succeeds with both params - named first', () async {
        final result = await Process.run('err_hybrid_missing', ['-n', 'named_value', 'pos_value']);
        expect(result.stdout, equals('Named: named_value, Positional: pos_value\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with both params - positional first', () async {
        final result = await Process.run('err_hybrid_missing', ['pos_value', '-n', 'named_value']);
        expect(result.stdout, equals('Named: named_value, Positional: pos_value\n'));
        expect(result.exitCode, equals(0));
      });
    });
  });

  group('Error Cases - Switch Commands', () {
    group('err_switch_missing_param', () {
      test('fails when selecting opt1 without required param', () async {
        final result = await Process.run('err_switch_missing_param', ['opt1']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
      });

      test('succeeds when selecting opt1 with required param', () async {
        final result = await Process.run('err_switch_missing_param', ['opt1', '-r', 'value']);
        expect(result.stdout, equals('Opt1: value\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds when selecting opt2 (no params required)', () async {
        final result = await Process.run('err_switch_missing_param', ['opt2']);
        expect(result.stdout, equals('Option 2\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with default option (opt2, no params)', () async {
        final result = await Process.run('err_switch_missing_param', []);
        expect(result.stdout, equals('Option 2\n'));
        expect(result.exitCode, equals(0));
      });
    });
  });

  group('Error Cases - Nested Switches', () {
    group('err_nested_missing_param', () {
      test('fails when selecting child1 without required param', () async {
        final result = await Process.run('err_nested_missing_param', ['parent1', 'child1']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
      });

      test('succeeds when selecting child1 with required param', () async {
        final result = await Process.run('err_nested_missing_param', ['parent1', 'child1', '-r', 'value']);
        expect(result.stdout, equals('P1C1: value\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds when selecting child2 (no params)', () async {
        final result = await Process.run('err_nested_missing_param', ['parent1', 'child2']);
        expect(result.stdout, equals('P1C2\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with default child1 and param', () async {
        final result = await Process.run('err_nested_missing_param', ['-r', 'value']);
        expect(result.stdout, equals('P1C1: value\n'));
        expect(result.exitCode, equals(0));
      });
    });

    group('err_deep_nested_error', () {
      test('fails at deep level without required param', () async {
        final result = await Process.run('err_deep_nested_error', []);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
      });

      test('fails with explicit path without required param', () async {
        final result = await Process.run('err_deep_nested_error', ['level1', 'level2', 'level3']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
      });

      test('succeeds with explicit path and required param', () async {
        final result = await Process.run('err_deep_nested_error', ['level1', 'level2', 'level3', '-r', 'value']);
        expect(result.stdout, equals('Deep: value\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with default path and required param', () async {
        final result = await Process.run('err_deep_nested_error', ['-r', 'value']);
        expect(result.stdout, equals('Deep: value\n'));
        expect(result.exitCode, equals(0));
      });
    });
  });

  group('Error Cases - Help and Info', () {
    test('err_missing_named_req --help shows help', () async {
      final result = await Process.run('err_missing_named_req', ['--help']);
      expect(
        result.stdout,
        equals(
          '${blue}err_missing_named_req$reset: ${gray}Test missing required named param$reset\n'
          'params:\n'
          '  required:\n'
          '    ${magenta}req (-r, --required)$reset\n',
        ),
      );
      expect(result.exitCode, equals(0));
    });
  });

  group('Error Cases - Mixed Params Edge Cases', () {
    group('err_mixed_params_missing', () {
      test('fails without any required params', () async {
        final result = await Process.run('err_mixed_params_missing', []);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Missing required'));
      });

      test('fails with only named required param', () async {
        final result = await Process.run('err_mixed_params_missing', ['-r', 'R1']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Missing required'));
      });

      test('fails with only positional required param', () async {
        final result = await Process.run('err_mixed_params_missing', ['R2']);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Missing required'));
      });

      test('succeeds with both required params and defaults for optional', () async {
        final result = await Process.run('err_mixed_params_missing', ['-r', 'R1', 'R2']);
        expect(result.stdout, equals('R1: R1, R2: R2, O1: o1, O2: o2\n'));
        expect(result.exitCode, equals(0));
      });

      test('succeeds with all params specified', () async {
        final result = await Process.run('err_mixed_params_missing', ['-r', 'R1', 'R2', 'O1', '-o', 'O2']);
        expect(result.stdout, equals('R1: R1, R2: R2, O1: O1, O2: O2\n'));
        expect(result.exitCode, equals(0));
      });
    });
  });
}
