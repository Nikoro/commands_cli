import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  // Level 11: Deeply nested switches
  group('nest8_deep_default', () {
    test('runs all defaults (level1 level2a level3a)', () async {
      final result = await Process.run('nest8_deep_default', []);
      expect(result.stdout, equals('L1 L2a L3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs level1 level2a level3b', () async {
      final result = await Process.run('nest8_deep_default', ['level1', 'level2a', 'level3b']);
      expect(result.stdout, equals('L1 L2a L3b\n'));
    });

    test('runs level1 level2b default (level3b)', () async {
      final result = await Process.run('nest8_deep_default', ['level1', 'level2b']);
      expect(result.stdout, equals('L1 L2b L3b\n'));
    });

    test('runs level1 level2b level3a', () async {
      final result = await Process.run('nest8_deep_default', ['level1', 'level2b', 'level3a']);
      expect(result.stdout, equals('L1 L2b L3a\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest8_deep_default', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest8_deep_default$reset: ${gray}2-level nested with defaults$reset\n'
            'options:\n'
            '  ${blue}level1$reset\n'
            '  options:\n'
            '    ${blue}level2a$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n'
            '      ${bold}default$reset: ${blue}level3a$reset\n'
            '    ${blue}level2b$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n'
            '      ${bold}default$reset: ${blue}level3b$reset\n'
            '    ${bold}default$reset: ${blue}level2a$reset\n'
            '  ${bold}default$reset: ${blue}level1$reset\n',
          ),
        );
      });
    }
  });

  group('nest9_deep_menu', () {
    test('requires all levels to be specified', () async {
      final result = await Process.run('nest9_deep_menu', []);
      expect(result.exitCode, isNot(0));
    });

    test('requires level3 when level2 specified', () async {
      final result = await Process.run('nest9_deep_menu', ['level1', 'level2a']);
      expect(result.exitCode, isNot(0));
    });

    test('runs level1 level2a level3a', () async {
      final result = await Process.run('nest9_deep_menu', ['level1', 'level2a', 'level3a']);
      expect(result.stdout, equals('Menu L1 L2a L3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs level1 level2a level3b', () async {
      final result = await Process.run('nest9_deep_menu', ['level1', 'level2a', 'level3b']);
      expect(result.stdout, equals('Menu L1 L2a L3b\n'));
    });

    test('runs level1 level2b level3a', () async {
      final result = await Process.run('nest9_deep_menu', ['level1', 'level2b', 'level3a']);
      expect(result.stdout, equals('Menu L1 L2b L3a\n'));
    });

    test('runs level1 level2b level3b', () async {
      final result = await Process.run('nest9_deep_menu', ['level1', 'level2b', 'level3b']);
      expect(result.stdout, equals('Menu L1 L2b L3b\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest9_deep_menu', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest9_deep_menu$reset: ${gray}2-level nested interactive menu$reset\n'
            'options:\n'
            '  ${blue}level1$reset\n'
            '  options:\n'
            '    ${blue}level2a$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n'
            '    ${blue}level2b$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n',
          ),
        );
      });
    }
  });

  group('nest10_deep_mixed_named', () {
    test('runs all defaults with default param', () async {
      final result = await Process.run('nest10_deep_mixed_named', []);
      expect(result.stdout, equals('L1 L2a L3a: l3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs defaults with custom param', () async {
      final result = await Process.run('nest10_deep_mixed_named', ['-v', 'custom']);
      expect(result.stdout, equals('L1 L2a L3a: custom\n'));
    });

    test('runs level1 level2a level3b', () async {
      final result = await Process.run('nest10_deep_mixed_named', ['level1', 'level2a', 'level3b']);
      expect(result.stdout, equals('L1 L2a L3b\n'));
    });

    test('level2b requires level3 selection', () async {
      final result = await Process.run('nest10_deep_mixed_named', ['level1', 'level2b']);
      expect(result.exitCode, isNot(0));
    });

    test('runs level1 level2b level3a', () async {
      final result = await Process.run('nest10_deep_mixed_named', ['level1', 'level2b', 'level3a']);
      expect(result.stdout, equals('L1 L2b L3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs level1 level2b level3b', () async {
      final result = await Process.run('nest10_deep_mixed_named', ['level1', 'level2b', 'level3b']);
      expect(result.stdout, equals('L1 L2b L3b\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest10_deep_mixed_named', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest10_deep_mixed_named$reset: ${gray}2-level nested mixed defaults/menus with named params$reset\n'
            'options:\n'
            '  ${blue}level1$reset: ${gray}First level1$reset\n'
            '  options:\n'
            '    ${blue}level2a$reset: ${gray}Has default$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset: ${gray}With named param$reset\n'
            '      params:\n'
            '        optional:\n'
            '          ${magenta}val (-v, --value)$reset\n'
            '          ${bold}default$reset: "l3a"\n'
            '      ${blue}level3b$reset\n'
            '      ${bold}default$reset: ${blue}level3a$reset\n'
            '    ${blue}level2b$reset: ${gray}No default (menu)$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n'
            '    ${bold}default$reset: ${blue}level2a$reset\n'
            '  ${bold}default$reset: ${blue}level1$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 11: Positional and Hybrid Deeply Nested
  // ============================================================================

  group('nest10_deep_mixed_positional', () {
    test('runs all defaults with default param', () async {
      final result = await Process.run('nest10_deep_mixed_positional', []);
      expect(result.stdout, equals('L1 L2a L3a: l3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs defaults with custom positional param', () async {
      final result = await Process.run('nest10_deep_mixed_positional', ['custom']);
      expect(result.stdout, equals('L1 L2a L3a: custom\n'));
    });

    test('runs level1 level2a level3b', () async {
      final result = await Process.run('nest10_deep_mixed_positional', ['level1', 'level2a', 'level3b']);
      expect(result.stdout, equals('L1 L2a L3b\n'));
    });

    test('level2b requires level3 selection', () async {
      final result = await Process.run('nest10_deep_mixed_positional', ['level1', 'level2b']);
      expect(result.exitCode, isNot(0));
    });

    test('runs level1 level2b level3a', () async {
      final result = await Process.run('nest10_deep_mixed_positional', ['level1', 'level2b', 'level3a']);
      expect(result.stdout, equals('L1 L2b L3a\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs level1 level2b level3b', () async {
      final result = await Process.run('nest10_deep_mixed_positional', ['level1', 'level2b', 'level3b']);
      expect(result.stdout, equals('L1 L2b L3b\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest10_deep_mixed_positional', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest10_deep_mixed_positional$reset: ${gray}2-level nested mixed defaults/menus with positional params$reset\n'
            'options:\n'
            '  ${blue}level1$reset: ${gray}First level1$reset\n'
            '  options:\n'
            '    ${blue}level2a$reset: ${gray}Has default$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset: ${gray}With positional param$reset\n'
            '      params:\n'
            '        optional:\n'
            '          ${magenta}val$reset\n'
            '          ${bold}default$reset: "l3a"\n'
            '      ${blue}level3b$reset\n'
            '      ${bold}default$reset: ${blue}level3a$reset\n'
            '    ${blue}level2b$reset: ${gray}No default (menu)$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset\n'
            '      ${blue}level3b$reset\n'
            '    ${bold}default$reset: ${blue}level2a$reset\n'
            '  ${bold}default$reset: ${blue}level1$reset\n',
          ),
        );
      });
    }
  });

  group('nest11_deep_hybrid', () {
    test('default level1 level2a level3a requires named required param', () async {
      final result = await Process.run('nest11_deep_hybrid', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs default with named required param', () async {
      final result = await Process.run('nest11_deep_hybrid', ['-r', 'req_val']);
      expect(result.stdout, equals('L1 L2a L3a: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs level1 level2a level3b with named optional default', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2a', 'level3b']);
      expect(result.stdout, equals('L1 L2a L3b: l3b\n'));
    });

    test('runs level1 level2a level3b with custom named optional', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2a', 'level3b', '-o', 'custom']);
      expect(result.stdout, equals('L1 L2a L3b: custom\n'));
    });

    test('level1 level2b level3a requires positional required param', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2b', 'level3a']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs level1 level2b level3a with positional required', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2b', 'level3a', 'req_val']);
      expect(result.stdout, equals('L1 L2b L3a: req_val\n'));
    });

    test('runs level1 level2b level3b with positional optional default', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2b', 'level3b']);
      expect(result.stdout, equals('L1 L2b L3b: l3b\n'));
    });

    test('runs level1 level2b level3b with custom positional optional', () async {
      final result = await Process.run('nest11_deep_hybrid', ['level1', 'level2b', 'level3b', 'custom']);
      expect(result.stdout, equals('L1 L2b L3b: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest11_deep_hybrid', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest11_deep_hybrid$reset: ${gray}2-level nested with mixed named/positional params$reset\n'
            'options:\n'
            '  ${blue}level1$reset: ${gray}First level1 with named params$reset\n'
            '  options:\n'
            '    ${blue}level2a$reset: ${gray}Has default with named req param$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset: ${gray}Named required$reset\n'
            '      params:\n'
            '        required:\n'
            '          ${magenta}req (-r, --required)$reset\n'
            '      ${blue}level3b$reset: ${gray}Named optional$reset\n'
            '      params:\n'
            '        optional:\n'
            '          ${magenta}opt (-o, --optional)$reset\n'
            '          ${bold}default$reset: "l3b"\n'
            '      ${bold}default$reset: ${blue}level3a$reset\n'
            '    ${blue}level2b$reset: ${gray}Positional params$reset\n'
            '    options:\n'
            '      ${blue}level3a$reset: ${gray}Positional required$reset\n'
            '      params:\n'
            '        required:\n'
            '          ${magenta}req$reset\n'
            '      ${blue}level3b$reset: ${gray}Positional optional$reset\n'
            '      params:\n'
            '        optional:\n'
            '          ${magenta}opt$reset\n'
            '          ${bold}default$reset: "l3b"\n'
            '    ${bold}default$reset: ${blue}level2a$reset\n'
            '  ${bold}default$reset: ${blue}level1$reset\n',
          ),
        );
      });
    }
  });
}
