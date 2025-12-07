import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  // Level 9: Simple nested switches
  group('nest1_default_no_comment', () {
    test('runs default parent and child', () async {
      final result = await Process.run('nest1_default_no_comment', []);
      expect(result.stdout, equals('Parent1 Child1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent1 child2', () async {
      final result = await Process.run('nest1_default_no_comment', ['parent1', 'child2']);
      expect(result.stdout, equals('Parent1 Child2\n'));
    });

    test('runs parent2 default child', () async {
      final result = await Process.run('nest1_default_no_comment', ['parent2']);
      expect(result.stdout, equals('Parent2 Child2\n'));
    });

    test('runs parent2 child1', () async {
      final result = await Process.run('nest1_default_no_comment', ['parent2', 'child1']);
      expect(result.stdout, equals('Parent2 Child1\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest1_default_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest1_default_no_comment$reset\n'
            'options:\n'
            '  ${blue}parent1$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    ${blue}child2$reset\n'
            '    ${bold}default$reset: ${blue}child1$reset\n'
            '  ${blue}parent2$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    ${blue}child2$reset\n'
            '    ${bold}default$reset: ${blue}child2$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });

  group('nest2_default_with_comment', () {
    test('runs default parent (parent2) and child', () async {
      final result = await Process.run('nest2_default_with_comment', []);
      expect(result.stdout, equals('Parent2 Child2\n'));
    });

    test('runs parent1 default child', () async {
      final result = await Process.run('nest2_default_with_comment', ['parent1']);
      expect(result.stdout, equals('Parent1 Child1\n'));
    });

    test('runs parent1 child2', () async {
      final result = await Process.run('nest2_default_with_comment', ['parent1', 'child2']);
      expect(result.stdout, equals('Parent1 Child2\n'));
    });

    test('runs parent2 child1', () async {
      final result = await Process.run('nest2_default_with_comment', ['parent2', 'child1']);
      expect(result.stdout, equals('Parent2 Child1\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest2_default_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest2_default_with_comment$reset: ${gray}Nested switches with comments$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n'
            '    ${bold}default$reset: ${blue}child1$reset\n'
            '  ${blue}parent2$reset: ${gray}Second parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n'
            '    ${bold}default$reset: ${blue}child2$reset\n'
            '  ${bold}default$reset: ${blue}parent2$reset\n',
          ),
        );
      });
    }
  });

  group('nest3_menu_no_comment', () {
    test('requires parent selection', () async {
      final result = await Process.run('nest3_menu_no_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('requires child selection when parent specified', () async {
      final result = await Process.run('nest3_menu_no_comment', ['parent1']);
      expect(result.exitCode, isNot(0));
    });

    test('runs parent1 child1', () async {
      final result = await Process.run('nest3_menu_no_comment', ['parent1', 'child1']);
      expect(result.stdout, equals('Menu Parent1 Child1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent2 child2', () async {
      final result = await Process.run('nest3_menu_no_comment', ['parent2', 'child2']);
      expect(result.stdout, equals('Menu Parent2 Child2\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest3_menu_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest3_menu_no_comment$reset\n'
            'options:\n'
            '  ${blue}parent1$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    ${blue}child2$reset\n'
            '  ${blue}parent2$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    ${blue}child2$reset\n',
          ),
        );
      });
    }
  });

  group('nest4_menu_with_comment', () {
    test('requires parent selection', () async {
      final result = await Process.run('nest4_menu_with_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('requires child selection', () async {
      final result = await Process.run('nest4_menu_with_comment', ['parent1']);
      expect(result.exitCode, isNot(0));
    });

    test('runs parent1 child1', () async {
      final result = await Process.run('nest4_menu_with_comment', ['parent1', 'child1']);
      expect(result.stdout, equals('Menu Parent1 Child1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent2 child2', () async {
      final result = await Process.run('nest4_menu_with_comment', ['parent2', 'child2']);
      expect(result.stdout, equals('Menu Parent2 Child2\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest4_menu_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest4_menu_with_comment$reset: ${gray}Nested interactive menu with comments$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n'
            '  ${blue}parent2$reset: ${gray}Second parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n',
          ),
        );
      });
    }
  });

  // Level 10: Nested switches with params
  group('nest5_default_named_params_no_comment', () {
    test('runs default parent/child with default param', () async {
      final result = await Process.run('nest5_default_named_params_no_comment', []);
      expect(result.stdout, equals('P1C1: p1c1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs default with custom param', () async {
      final result = await Process.run('nest5_default_named_params_no_comment', ['-v', 'custom']);
      expect(result.stdout, equals('P1C1: custom\n'));
    });

    test('runs parent1 child2 with default param', () async {
      final result = await Process.run('nest5_default_named_params_no_comment', ['parent1', 'child2']);
      expect(result.stdout, equals('P1C2: p1c2\n'));
    });

    test('runs parent1 child2 with custom param', () async {
      final result = await Process.run('nest5_default_named_params_no_comment', [
        'parent1',
        'child2',
        '--value',
        'test',
      ]);
      expect(result.stdout, equals('P1C2: test\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest5_default_named_params_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest5_default_named_params_no_comment$reset\n'
            'options:\n'
            '  ${blue}parent1$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val (-v, --value)$reset\n'
            '        ${bold}default$reset: "p1c1"\n'
            '    ${blue}child2$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val (-v, --value)$reset\n'
            '        ${bold}default$reset: "p1c2"\n'
            '    ${bold}default$reset: ${blue}child1$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });

  group('nest6_default_named_params_with_comment', () {
    test('runs default parent/child (parent1 child2)', () async {
      final result = await Process.run('nest6_default_named_params_with_comment', []);
      expect(result.stdout, equals('P1C2: p1c2\n'));
    });

    test('runs parent1 child1 with custom param', () async {
      final result = await Process.run('nest6_default_named_params_with_comment', [
        'parent1',
        'child1',
        '-v',
        'custom',
      ]);
      expect(result.stdout, equals('P1C1: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest6_default_named_params_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest6_default_named_params_with_comment$reset: ${gray}Nested with named params all commented$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val (-v, --value)$reset\n'
            '        ${bold}default$reset: "p1c1"\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val (-v, --value)$reset\n'
            '        ${bold}default$reset: "p1c2"\n'
            '    ${bold}default$reset: ${blue}child2$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });

  group('nest7_menu_named_params_mixed', () {
    test('requires parent selection', () async {
      final result = await Process.run('nest7_menu_named_params_mixed', []);
      expect(result.exitCode, isNot(0));
    });

    test('parent1 child1 requires required param', () async {
      final result = await Process.run('nest7_menu_named_params_mixed', ['parent1', 'child1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs parent1 child1 with required param', () async {
      final result = await Process.run('nest7_menu_named_params_mixed', ['parent1', 'child1', '-r', 'req_val']);
      expect(result.stdout, equals('P1C1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent1 child2 with default param', () async {
      final result = await Process.run('nest7_menu_named_params_mixed', ['parent1', 'child2']);
      expect(result.stdout, equals('P1C2: p1c2opt\n'));
    });

    test('runs parent2 child1 without params', () async {
      final result = await Process.run('nest7_menu_named_params_mixed', ['parent2', 'child1']);
      expect(result.stdout, equals('P2C1\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest7_menu_named_params_mixed', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest7_menu_named_params_mixed$reset: ${gray}Nested menu with mixed named params and comments$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent with required param$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    params:\n'
            '      required:\n'
            '        ${magenta}req (-r, --required)$reset\n'
            '    ${blue}child2$reset: ${gray}Second child with optional param$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}opt (-o, --optional)$reset\n'
            '        ${bold}default$reset: "p1c2opt"\n'
            '  ${blue}parent2$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}Child without params$reset\n'
            '    ${blue}child2$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val (-v, --value)$reset\n'
            '        ${bold}default$reset: "p2c2"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 10b: Positional Nested Switches with Params
  // ============================================================================

  group('nest5_default_positional_params_no_comment', () {
    test('runs default parent/child with default param', () async {
      final result = await Process.run('nest5_default_positional_params_no_comment', []);
      expect(result.stdout, equals('P1C1: p1c1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs default with custom param', () async {
      final result = await Process.run('nest5_default_positional_params_no_comment', ['custom']);
      expect(result.stdout, equals('P1C1: custom\n'));
    });

    test('runs parent1 child2 with custom param', () async {
      final result = await Process.run('nest5_default_positional_params_no_comment', ['parent1', 'child2', 'custom']);
      expect(result.stdout, equals('P1C2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest5_default_positional_params_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest5_default_positional_params_no_comment$reset\n'
            'options:\n'
            '  ${blue}parent1$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val$reset\n'
            '        ${bold}default$reset: "p1c1"\n'
            '    ${blue}child2$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val$reset\n'
            '        ${bold}default$reset: "p1c2"\n'
            '    ${bold}default$reset: ${blue}child1$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });

  group('nest6_default_positional_params_with_comment', () {
    test('runs default parent/child (parent1 child2)', () async {
      final result = await Process.run('nest6_default_positional_params_with_comment', []);
      expect(result.stdout, equals('P1C2: p1c2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent1 child1 with custom param', () async {
      final result = await Process.run('nest6_default_positional_params_with_comment', ['parent1', 'child1', 'custom']);
      expect(result.stdout, equals('P1C1: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest6_default_positional_params_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest6_default_positional_params_with_comment$reset: ${gray}Nested with positional params all commented$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}First child$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val$reset\n'
            '        ${bold}default$reset: "p1c1"\n'
            '    ${blue}child2$reset: ${gray}Second child$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val$reset\n'
            '        ${bold}default$reset: "p1c2"\n'
            '    ${bold}default$reset: ${blue}child2$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });

  group('nest7_menu_positional_params_mixed', () {
    test('requires parent selection', () async {
      final result = await Process.run('nest7_menu_positional_params_mixed', []);
      expect(result.exitCode, isNot(0));
    });

    test('parent1 child1 requires required param', () async {
      final result = await Process.run('nest7_menu_positional_params_mixed', ['parent1', 'child1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs parent1 child1 with required param', () async {
      final result = await Process.run('nest7_menu_positional_params_mixed', ['parent1', 'child1', 'req_val']);
      expect(result.stdout, equals('P1C1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent1 child2 with default param', () async {
      final result = await Process.run('nest7_menu_positional_params_mixed', ['parent1', 'child2']);
      expect(result.stdout, equals('P1C2: p1c2opt\n'));
    });

    test('runs parent2 child1 without params', () async {
      final result = await Process.run('nest7_menu_positional_params_mixed', ['parent2', 'child1']);
      expect(result.stdout, equals('P2C1\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest7_menu_positional_params_mixed', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest7_menu_positional_params_mixed$reset: ${gray}Nested menu with mixed positional params and comments$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}First parent with required param$reset\n'
            '  options:\n'
            '    ${blue}child1$reset\n'
            '    params:\n'
            '      required:\n'
            '        ${magenta}req$reset\n'
            '    ${blue}child2$reset: ${gray}Second child with optional param$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}opt$reset\n'
            '        ${bold}default$reset: "p1c2opt"\n'
            '  ${blue}parent2$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}Child without params$reset\n'
            '    ${blue}child2$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}val$reset\n'
            '        ${bold}default$reset: "p2c2"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 10c: Hybrid Nested Switches with Params
  // ============================================================================

  group('nest8_hybrid_params', () {
    test('requires parent1 child1 named required param', () async {
      final result = await Process.run('nest8_hybrid_params', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs default parent1 child1 with named required', () async {
      final result = await Process.run('nest8_hybrid_params', ['-r', 'req_val']);
      expect(result.stdout, equals('P1C1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs parent1 child2 with positional optional default', () async {
      final result = await Process.run('nest8_hybrid_params', ['parent1', 'child2']);
      expect(result.stdout, equals('P1C2: p1c2\n'));
    });

    test('runs parent1 child2 with custom positional param', () async {
      final result = await Process.run('nest8_hybrid_params', ['parent1', 'child2', 'custom']);
      expect(result.stdout, equals('P1C2: custom\n'));
    });

    test('runs parent2 default child2 with named optional default', () async {
      final result = await Process.run('nest8_hybrid_params', ['parent2']);
      expect(result.stdout, equals('P2C2: p2c2\n'));
    });

    test('runs parent2 child1 with positional required', () async {
      final result = await Process.run('nest8_hybrid_params', ['parent2', 'child1', 'req_val']);
      expect(result.stdout, equals('P2C1: req_val\n'));
    });

    test('runs parent2 child2 with named optional custom', () async {
      final result = await Process.run('nest8_hybrid_params', ['parent2', 'child2', '-o', 'custom']);
      expect(result.stdout, equals('P2C2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('nest8_hybrid_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}nest8_hybrid_params$reset: ${gray}Nested with mixed named/positional params$reset\n'
            'options:\n'
            '  ${blue}parent1$reset: ${gray}Parent with named params$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}Named required$reset\n'
            '    params:\n'
            '      required:\n'
            '        ${magenta}req (-r, --required)$reset\n'
            '    ${blue}child2$reset: ${gray}Positional optional$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}opt$reset\n'
            '        ${bold}default$reset: "p1c2"\n'
            '    ${bold}default$reset: ${blue}child1$reset\n'
            '  ${blue}parent2$reset: ${gray}Parent with positional params$reset\n'
            '  options:\n'
            '    ${blue}child1$reset: ${gray}Positional required$reset\n'
            '    params:\n'
            '      required:\n'
            '        ${magenta}req$reset\n'
            '    ${blue}child2$reset: ${gray}Named optional$reset\n'
            '    params:\n'
            '      optional:\n'
            '        ${magenta}opt (-o, --optional)$reset\n'
            '        ${bold}default$reset: "p2c2"\n'
            '    ${bold}default$reset: ${blue}child2$reset\n'
            '  ${bold}default$reset: ${blue}parent1$reset\n',
          ),
        );
      });
    }
  });
}
