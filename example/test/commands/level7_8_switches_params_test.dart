import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('sw7_default_single_named_param_no_comment', () {
    test('runs default option with default param', () async {
      final result = await Process.run('sw7_default_single_named_param_no_comment', []);
      expect(result.stdout, equals('Opt1: v1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs default option with custom param', () async {
      final result = await Process.run('sw7_default_single_named_param_no_comment', ['-v', 'custom']);
      expect(result.stdout, equals('Opt1: custom\n'));
    });

    test('runs opt2 with default param', () async {
      final result = await Process.run('sw7_default_single_named_param_no_comment', ['opt2']);
      expect(result.stdout, equals('Opt2: v2\n'));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw7_default_single_named_param_no_comment', ['opt2', '-v', 'custom']);
      expect(result.stdout, equals('Opt2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw7_default_single_named_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw7_default_single_named_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw8_default_single_named_param_with_comment', () {
    test('runs default option', () async {
      final result = await Process.run('sw8_default_single_named_param_with_comment', []);
      expect(result.stdout, equals('Opt1: v1\n'));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw8_default_single_named_param_with_comment', ['opt2', '--value', 'test']);
      expect(result.stdout, equals('Opt2: test\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw8_default_single_named_param_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw8_default_single_named_param_with_comment$reset: ${gray}Switch with default and named params commented$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset: ${gray}Second option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw9_default_multi_named_param_no_comment', () {
    test('runs default option (opt2) with defaults', () async {
      final result = await Process.run('sw9_default_multi_named_param_no_comment', []);
      expect(result.stdout, equals('Opt2: A2, B2\n'));
    });

    test('runs opt1 with defaults', () async {
      final result = await Process.run('sw9_default_multi_named_param_no_comment', ['opt1']);
      expect(result.stdout, equals('Opt1: A1, B1\n'));
    });

    test('runs opt1 with custom params', () async {
      final result = await Process.run('sw9_default_multi_named_param_no_comment', ['opt1', '-a', 'X', '-b', 'Y']);
      expect(result.stdout, equals('Opt1: X, Y\n'));
    });

    test('runs opt2 with partial custom params', () async {
      final result = await Process.run('sw9_default_multi_named_param_no_comment', ['opt2', '-a', 'X']);
      expect(result.stdout, equals('Opt2: X, B2\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw9_default_multi_named_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw9_default_multi_named_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B2"\n'
            '  ${bold}default$reset: ${blue}opt2$reset\n',
          ),
        );
      });
    }
  });

  group('sw10_default_multi_named_param_mixed_comment', () {
    test('runs default option (opt1) with defaults', () async {
      final result = await Process.run('sw10_default_multi_named_param_mixed_comment', []);
      expect(result.stdout, equals('Opt1: A1, B1\n'));
    });

    test('runs opt2 with defaults', () async {
      final result = await Process.run('sw10_default_multi_named_param_mixed_comment', ['opt2']);
      expect(result.stdout, equals('Opt2: A2, B2\n'));
    });

    test('runs with custom params', () async {
      final result = await Process.run('sw10_default_multi_named_param_mixed_comment', [
        'opt1',
        '--alpha',
        'X',
        '--beta',
        'Y',
      ]);
      expect(result.stdout, equals('Opt1: X, Y\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw10_default_multi_named_param_mixed_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw10_default_multi_named_param_mixed_comment$reset: ${gray}Switch with multi named params mixed comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw11_default_named_req_opt_params', () {
    test('fails without required param', () async {
      final result = await Process.run('sw11_default_named_req_opt_params', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs default option (opt2) with required param', () async {
      final result = await Process.run('sw11_default_named_req_opt_params', ['-r', 'req_val']);
      expect(result.stdout, equals('Opt2: req_val, opt2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with required param', () async {
      final result = await Process.run('sw11_default_named_req_opt_params', ['opt1', '-r', 'req_val']);
      expect(result.stdout, equals('Opt1: req_val, opt1\n'));
    });

    test('runs with both required and optional params', () async {
      final result = await Process.run('sw11_default_named_req_opt_params', ['opt1', '-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Opt1: req_val, opt_val\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw11_default_named_req_opt_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw11_default_named_req_opt_params$reset: ${gray}Switch with named required and optional params$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req (-r, --required)$reset\n'
            '    optional:\n'
            '      ${magenta}opt (-o, --optional)$reset\n'
            '      ${bold}default$reset: "opt1"\n'
            '  ${blue}opt2$reset: ${gray}Second option$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req (-r, --required)$reset\n'
            '    optional:\n'
            '      ${magenta}opt (-o, --optional)$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${bold}default$reset: ${blue}opt2$reset\n',
          ),
        );
      });
    }
  });

  // Level 8: Switches with parameters, no defaults (interactive menu)
  group('sw13_menu_single_named_param_no_comment', () {
    test('requires option selection', () async {
      final result = await Process.run('sw13_menu_single_named_param_no_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1 with default param', () async {
      final result = await Process.run('sw13_menu_single_named_param_no_comment', ['opt1']);
      expect(result.stdout, equals('Menu Opt1: v1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with custom param', () async {
      final result = await Process.run('sw13_menu_single_named_param_no_comment', ['opt1', '-v', 'custom']);
      expect(result.stdout, equals('Menu Opt1: custom\n'));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw13_menu_single_named_param_no_comment', ['opt2', '--value', 'test']);
      expect(result.stdout, equals('Menu Opt2: test\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw13_menu_single_named_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw13_menu_single_named_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val (-v, --value)$reset\n'
            '      ${bold}default$reset: "v2"\n',
          ),
        );
      });
    }
  });

  group('sw14_menu_multi_named_param_partial_comment', () {
    test('requires option selection', () async {
      final result = await Process.run('sw14_menu_multi_named_param_partial_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1 with defaults', () async {
      final result = await Process.run('sw14_menu_multi_named_param_partial_comment', ['opt1']);
      expect(result.stdout, equals('Menu Opt1: A1, B1\n'));
    });

    test('runs opt2 with custom params', () async {
      final result = await Process.run('sw14_menu_multi_named_param_partial_comment', ['opt2', '-a', 'X', '-b', 'Y']);
      expect(result.stdout, equals('Menu Opt2: X, Y\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw14_menu_multi_named_param_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw14_menu_multi_named_param_partial_comment$reset: ${gray}Interactive menu with named params partial comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a (-a, --alpha)$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b (-b, --beta)$reset\n'
            '      ${bold}default$reset: "B2"\n',
          ),
        );
      });
    }
  });

  group('sw15_menu_mixed_named_params', () {
    test('requires option selection', () async {
      final result = await Process.run('sw15_menu_mixed_named_params', []);
      expect(result.exitCode, isNot(0));
    });

    test('opt1 requires required param', () async {
      final result = await Process.run('sw15_menu_mixed_named_params', ['opt1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs opt1 with required param', () async {
      final result = await Process.run('sw15_menu_mixed_named_params', ['opt1', '-r', 'req_val']);
      expect(result.stdout, equals('Menu Opt1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw15_menu_mixed_named_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw15_menu_mixed_named_params$reset: ${gray}Interactive menu with mixed named param types$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}Option with required param$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req (-r, --required)$reset\n'
            '  ${blue}opt2$reset: ${gray}Option with optional param$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}opt (-o, --optional)$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${blue}opt3$reset: ${gray}Option without params$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 7b: Positional Switch Commands with Params - Defaults
  // ============================================================================

  group('sw7_default_single_positional_param_no_comment', () {
    test('runs default option with default param', () async {
      final result = await Process.run('sw7_default_single_positional_param_no_comment', []);
      expect(result.stdout, equals('Opt1: v1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs default option with custom param', () async {
      final result = await Process.run('sw7_default_single_positional_param_no_comment', ['custom']);
      expect(result.stdout, equals('Opt1: custom\n'));
    });

    test('runs opt2 with default param', () async {
      final result = await Process.run('sw7_default_single_positional_param_no_comment', ['opt2']);
      expect(result.stdout, equals('Opt2: v2\n'));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw7_default_single_positional_param_no_comment', ['opt2', 'custom']);
      expect(result.stdout, equals('Opt2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw7_default_single_positional_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw7_default_single_positional_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw8_default_single_positional_param_with_comment', () {
    test('runs default option', () async {
      final result = await Process.run('sw8_default_single_positional_param_with_comment', []);
      expect(result.stdout, equals('Opt1: v1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw8_default_single_positional_param_with_comment', ['opt2', 'custom']);
      expect(result.stdout, equals('Opt2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw8_default_single_positional_param_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw8_default_single_positional_param_with_comment$reset: ${gray}Switch with default and positional params commented$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset: ${gray}Second option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw9_default_multi_positional_param_no_comment', () {
    test('runs default option (opt2) with defaults', () async {
      final result = await Process.run('sw9_default_multi_positional_param_no_comment', []);
      expect(result.stdout, equals('Opt2: A2, B2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with defaults', () async {
      final result = await Process.run('sw9_default_multi_positional_param_no_comment', ['opt1']);
      expect(result.stdout, equals('Opt1: A1, B1\n'));
    });

    test('runs opt1 with custom params', () async {
      final result = await Process.run('sw9_default_multi_positional_param_no_comment', ['opt1', 'X', 'Y']);
      expect(result.stdout, equals('Opt1: X, Y\n'));
    });

    test('runs opt2 with partial custom params', () async {
      final result = await Process.run('sw9_default_multi_positional_param_no_comment', ['opt2', 'X']);
      expect(result.stdout, equals('Opt2: X, B2\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw9_default_multi_positional_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw9_default_multi_positional_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B2"\n'
            '  ${bold}default$reset: ${blue}opt2$reset\n',
          ),
        );
      });
    }
  });

  group('sw10_default_multi_positional_param_mixed_comment', () {
    test('runs default option (opt1) with defaults', () async {
      final result = await Process.run('sw10_default_multi_positional_param_mixed_comment', []);
      expect(result.stdout, equals('Opt1: A1, B1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2 with defaults', () async {
      final result = await Process.run('sw10_default_multi_positional_param_mixed_comment', ['opt2']);
      expect(result.stdout, equals('Opt2: A2, B2\n'));
    });

    test('runs with custom params', () async {
      final result = await Process.run('sw10_default_multi_positional_param_mixed_comment', ['opt2', 'X', 'Y']);
      expect(result.stdout, equals('Opt2: X, Y\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw10_default_multi_positional_param_mixed_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw10_default_multi_positional_param_mixed_comment$reset: ${gray}Switch with multi positional params mixed comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  group('sw11_default_positional_req_opt_params', () {
    test('fails without required param', () async {
      final result = await Process.run('sw11_default_positional_req_opt_params', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs default option (opt2) with required param', () async {
      final result = await Process.run('sw11_default_positional_req_opt_params', ['req_val']);
      expect(result.stdout, equals('Opt2: req_val, opt2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with required param', () async {
      final result = await Process.run('sw11_default_positional_req_opt_params', ['opt1', 'req_val']);
      expect(result.stdout, equals('Opt1: req_val, opt1\n'));
    });

    test('runs with both required and optional params', () async {
      final result = await Process.run('sw11_default_positional_req_opt_params', ['opt1', 'req_val', 'opt_val']);
      expect(result.stdout, equals('Opt1: req_val, opt_val\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw11_default_positional_req_opt_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw11_default_positional_req_opt_params$reset: ${gray}Switch with positional required and optional params$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req$reset\n'
            '    optional:\n'
            '      ${magenta}opt$reset\n'
            '      ${bold}default$reset: "opt1"\n'
            '  ${blue}opt2$reset: ${gray}Second option$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req$reset\n'
            '    optional:\n'
            '      ${magenta}opt$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${bold}default$reset: ${blue}opt2$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 7c: Hybrid Switch Commands with Params
  // ============================================================================

  group('sw12_default_hybrid_params', () {
    test('fails without required param for default option', () async {
      final result = await Process.run('sw12_default_hybrid_params', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs default option (opt1) with named required param', () async {
      final result = await Process.run('sw12_default_hybrid_params', ['-r', 'req_val']);
      expect(result.stdout, equals('Opt1: req_val, opt1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with named req and positional opt', () async {
      final result = await Process.run('sw12_default_hybrid_params', ['-r', 'req_val', 'opt_val']);
      expect(result.stdout, equals('Opt1: req_val, opt_val\n'));
    });

    test('runs opt2 with positional req and named opt', () async {
      final result = await Process.run('sw12_default_hybrid_params', ['opt2', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Opt2: req_val, opt_val\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw12_default_hybrid_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw12_default_hybrid_params$reset: ${gray}Switch with mixed named/positional params$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option - named req, positional opt$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req (-r, --required)$reset\n'
            '    optional:\n'
            '      ${magenta}opt$reset\n'
            '      ${bold}default$reset: "opt1"\n'
            '  ${blue}opt2$reset: ${gray}Second option - positional req, named opt$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req$reset\n'
            '    optional:\n'
            '      ${magenta}opt (-o, --optional)$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${bold}default$reset: ${blue}opt1$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 8b: Positional Menu Switch Commands with Params
  // ============================================================================

  group('sw13_menu_single_positional_param_no_comment', () {
    test('requires option selection', () async {
      final result = await Process.run('sw13_menu_single_positional_param_no_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1 with default param', () async {
      final result = await Process.run('sw13_menu_single_positional_param_no_comment', ['opt1']);
      expect(result.stdout, equals('Menu Opt1: v1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt1 with custom param', () async {
      final result = await Process.run('sw13_menu_single_positional_param_no_comment', ['opt1', 'custom']);
      expect(result.stdout, equals('Menu Opt1: custom\n'));
    });

    test('runs opt2 with custom param', () async {
      final result = await Process.run('sw13_menu_single_positional_param_no_comment', ['opt2', 'custom']);
      expect(result.stdout, equals('Menu Opt2: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw13_menu_single_positional_param_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw13_menu_single_positional_param_no_comment$reset\n'
            'options:\n'
            '  ${blue}opt1$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}val$reset\n'
            '      ${bold}default$reset: "v2"\n',
          ),
        );
      });
    }
  });

  group('sw14_menu_multi_positional_param_partial_comment', () {
    test('requires option selection', () async {
      final result = await Process.run('sw14_menu_multi_positional_param_partial_comment', []);
      expect(result.exitCode, isNot(0));
    });

    test('runs opt1 with defaults', () async {
      final result = await Process.run('sw14_menu_multi_positional_param_partial_comment', ['opt1']);
      expect(result.stdout, equals('Menu Opt1: A1, B1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2 with custom params', () async {
      final result = await Process.run('sw14_menu_multi_positional_param_partial_comment', ['opt2', 'X', 'Y']);
      expect(result.stdout, equals('Menu Opt2: X, Y\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw14_menu_multi_positional_param_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw14_menu_multi_positional_param_partial_comment$reset: ${gray}Interactive menu with positional params partial comments$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}First option$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A1"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B1"\n'
            '  ${blue}opt2$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}a$reset\n'
            '      ${bold}default$reset: "A2"\n'
            '      ${magenta}b$reset\n'
            '      ${bold}default$reset: "B2"\n',
          ),
        );
      });
    }
  });

  group('sw15_menu_mixed_positional_params', () {
    test('requires option selection', () async {
      final result = await Process.run('sw15_menu_mixed_positional_params', []);
      expect(result.exitCode, isNot(0));
    });

    test('opt1 requires required param', () async {
      final result = await Process.run('sw15_menu_mixed_positional_params', ['opt1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs opt1 with required param', () async {
      final result = await Process.run('sw15_menu_mixed_positional_params', ['opt1', 'req_val']);
      expect(result.stdout, equals('Menu Opt1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2 with default', () async {
      final result = await Process.run('sw15_menu_mixed_positional_params', ['opt2']);
      expect(result.stdout, equals('Menu Opt2: opt2\n'));
    });

    test('runs opt3 without params', () async {
      final result = await Process.run('sw15_menu_mixed_positional_params', ['opt3']);
      expect(result.stdout, equals('Menu Opt3\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw15_menu_mixed_positional_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw15_menu_mixed_positional_params$reset: ${gray}Interactive menu with mixed positional param types$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}Option with required param$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req$reset\n'
            '  ${blue}opt2$reset: ${gray}Option with optional param$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}opt$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${blue}opt3$reset: ${gray}Option without params$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 8c: Hybrid Menu Switch Commands with Params
  // ============================================================================

  group('sw16_menu_hybrid_params', () {
    test('requires option selection', () async {
      final result = await Process.run('sw16_menu_hybrid_params', []);
      expect(result.exitCode, isNot(0));
    });

    test('opt1 requires named required param', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs opt1 with named required param', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt1', '-r', 'req_val']);
      expect(result.stdout, equals('Menu Opt1: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs opt2 with positional optional default', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt2']);
      expect(result.stdout, equals('Menu Opt2: opt2\n'));
    });

    test('runs opt2 with custom positional param', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt2', 'custom']);
      expect(result.stdout, equals('Menu Opt2: custom\n'));
    });

    test('opt3 requires positional required param', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt3']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs opt3 with positional req and named opt default', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt3', 'req_val']);
      expect(result.stdout, equals('Menu Opt3: req_val, opt3\n'));
    });

    test('runs opt3 with both params', () async {
      final result = await Process.run('sw16_menu_hybrid_params', ['opt3', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Menu Opt3: req_val, opt_val\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('sw16_menu_hybrid_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}sw16_menu_hybrid_params$reset: ${gray}Interactive menu with mixed named/positional params$reset\n'
            'options:\n'
            '  ${blue}opt1$reset: ${gray}Named required param$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req (-r, --required)$reset\n'
            '  ${blue}opt2$reset: ${gray}Positional optional param$reset\n'
            '  params:\n'
            '    optional:\n'
            '      ${magenta}opt$reset\n'
            '      ${bold}default$reset: "opt2"\n'
            '  ${blue}opt3$reset: ${gray}Mixed params$reset\n'
            '  params:\n'
            '    required:\n'
            '      ${magenta}req$reset\n'
            '    optional:\n'
            '      ${magenta}opt (-o, --optional)$reset\n'
            '      ${bold}default$reset: "opt3"\n',
          ),
        );
      });
    }
  });
}
