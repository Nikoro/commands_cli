import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('p11_mix_named_req_first_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p11_mix_named_req_first_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param (uses optional default)', () async {
      final result = await Process.run('p11_mix_named_req_first_no_comment', ['-r', 'req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both required and optional params', () async {
      final result = await Process.run('p11_mix_named_req_first_no_comment', ['-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('accepts long flags', () async {
      final result = await Process.run('p11_mix_named_req_first_no_comment', [
        '--required',
        'req_val',
        '--optional',
        'opt_val',
      ]);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p11_mix_named_req_first_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p11_mix_named_req_first_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset\n'
            '    ${bold}default$reset: "opt1"\n',
          ),
        );
      });
    }
  });

  group('p12_mix_named_req_first_partial_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p12_mix_named_req_first_partial_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p12_mix_named_req_first_partial_comment', ['-r', 'req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p12_mix_named_req_first_partial_comment', ['-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p12_mix_named_req_first_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p12_mix_named_req_first_partial_comment$reset: ${gray}Mixed named params with partial comments$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset\n'
            '    ${bold}default$reset: "opt2"\n',
          ),
        );
      });
    }
  });

  group('p13_mix_named_req_first_all_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p13_mix_named_req_first_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p13_mix_named_req_first_all_comment', ['-r', 'req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt3\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p13_mix_named_req_first_all_comment', ['-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p13_mix_named_req_first_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p13_mix_named_req_first_all_comment$reset: ${gray}Mixed named params all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset ${gray}Optional param$reset\n'
            '    ${bold}default$reset: "opt3"\n',
          ),
        );
      });
    }
  });

  group('p14_mix_named_opt_first_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p14_mix_named_opt_first_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p14_mix_named_opt_first_no_comment', ['-r', 'req_val']);
      expect(result.stdout, equals('Opt: opt4, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p14_mix_named_opt_first_no_comment', ['-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Opt: opt_val, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('accepts long flags', () async {
      final result = await Process.run('p14_mix_named_opt_first_no_comment', [
        '--required',
        'req_val',
        '--optional',
        'opt_val',
      ]);
      expect(result.stdout, equals('Opt: opt_val, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p14_mix_named_opt_first_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p14_mix_named_opt_first_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset\n'
            '    ${bold}default$reset: "opt4"\n',
          ),
        );
      });
    }
  });

  group('p15_mix_named_opt_first_all_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p15_mix_named_opt_first_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p15_mix_named_opt_first_all_comment', ['-r', 'req_val']);
      expect(result.stdout, equals('Opt: opt5, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p15_mix_named_opt_first_all_comment', ['-r', 'req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Opt: opt_val, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p15_mix_named_opt_first_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p15_mix_named_opt_first_all_comment$reset: ${gray}Optional then required all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset ${gray}Optional param$reset\n'
            '    ${bold}default$reset: "opt5"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 4b: Positional Mixed Params Tests
  // ============================================================================

  group('p11_mix_positional_req_first_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p11_mix_positional_req_first_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required positional param (uses optional default)', () async {
      final result = await Process.run('p11_mix_positional_req_first_no_comment', ['req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both positional params', () async {
      final result = await Process.run('p11_mix_positional_req_first_no_comment', ['req_val', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p11_mix_positional_req_first_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p11_mix_positional_req_first_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset\n'
            '    ${bold}default$reset: "opt1"\n',
          ),
        );
      });
    }
  });

  group('p12_mix_positional_req_first_partial_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p12_mix_positional_req_first_partial_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p12_mix_positional_req_first_partial_comment', ['req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p12_mix_positional_req_first_partial_comment', ['req_val', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p12_mix_positional_req_first_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p12_mix_positional_req_first_partial_comment$reset: ${gray}Mixed positional params with partial comments$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset\n'
            '    ${bold}default$reset: "opt2"\n',
          ),
        );
      });
    }
  });

  group('p13_mix_positional_req_first_all_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p13_mix_positional_req_first_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p13_mix_positional_req_first_all_comment', ['req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt3\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params', () async {
      final result = await Process.run('p13_mix_positional_req_first_all_comment', ['req_val', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p13_mix_positional_req_first_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p13_mix_positional_req_first_all_comment$reset: ${gray}Mixed positional params all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset ${gray}Optional param$reset\n'
            '    ${bold}default$reset: "opt3"\n',
          ),
        );
      });
    }
  });

  group('p14_mix_positional_opt_first_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p14_mix_positional_opt_first_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param (uses optional default)', () async {
      final result = await Process.run('p14_mix_positional_opt_first_no_comment', ['req_val']);
      expect(result.stdout, equals('Opt: opt4, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params (required first, optional second)', () async {
      final result = await Process.run('p14_mix_positional_opt_first_no_comment', ['req_val', 'opt_val']);
      expect(result.stdout, equals('Opt: opt_val, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p14_mix_positional_opt_first_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p14_mix_positional_opt_first_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset\n'
            '    ${bold}default$reset: "opt4"\n',
          ),
        );
      });
    }
  });

  group('p15_mix_positional_opt_first_all_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p15_mix_positional_opt_first_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required param', () async {
      final result = await Process.run('p15_mix_positional_opt_first_all_comment', ['req_val']);
      expect(result.stdout, equals('Opt: opt5, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with both params (required first, optional second)', () async {
      final result = await Process.run('p15_mix_positional_opt_first_all_comment', ['req_val', 'opt_val']);
      expect(result.stdout, equals('Opt: opt_val, Req: req_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p15_mix_positional_opt_first_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p15_mix_positional_opt_first_all_comment$reset: ${gray}Optional then required all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset ${gray}Required param$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset ${gray}Optional param$reset\n'
            '    ${bold}default$reset: "opt5"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 4c: Hybrid Mixed Params Tests (Named/Positional Mix)
  // ============================================================================

  group('p16_mix_hybrid_req_named_opt_positional', () {
    test('fails without required param', () async {
      final result = await Process.run('p16_mix_hybrid_req_named_opt_positional', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required named param (uses optional default)', () async {
      final result = await Process.run('p16_mix_hybrid_req_named_opt_positional', ['-r', 'req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with required named and optional positional', () async {
      final result = await Process.run('p16_mix_hybrid_req_named_opt_positional', ['-r', 'req_val', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p16_mix_hybrid_req_named_opt_positional', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p16_mix_hybrid_req_named_opt_positional$reset: ${gray}Named required, positional optional$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset ${gray}Required named param$reset\n'
            '  optional:\n'
            '    ${magenta}opt$reset ${gray}Optional positional param$reset\n'
            '    ${bold}default$reset: "opt1"\n',
          ),
        );
      });
    }
  });

  group('p17_mix_hybrid_req_positional_opt_named', () {
    test('fails without required param', () async {
      final result = await Process.run('p17_mix_hybrid_req_positional_opt_named', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with only required positional param (uses optional default)', () async {
      final result = await Process.run('p17_mix_hybrid_req_positional_opt_named', ['req_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with required positional and optional named', () async {
      final result = await Process.run('p17_mix_hybrid_req_positional_opt_named', ['req_val', '-o', 'opt_val']);
      expect(result.stdout, equals('Req: req_val, Opt: opt_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p17_mix_hybrid_req_positional_opt_named', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p17_mix_hybrid_req_positional_opt_named$reset: ${gray}Positional required, named optional$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset ${gray}Required positional param$reset\n'
            '  optional:\n'
            '    ${magenta}opt (-o, --optional)$reset ${gray}Optional named param$reset\n'
            '    ${bold}default$reset: "opt2"\n',
          ),
        );
      });
    }
  });

  group('p18_mix_hybrid_multi_params', () {
    test('fails without required params', () async {
      final result = await Process.run('p18_mix_hybrid_multi_params', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}r2$reset\n'));
    });

    test('runs with only required params (uses optional defaults)', () async {
      final result = await Process.run('p18_mix_hybrid_multi_params', ['-r', 'r1_val', 'r2_val']);
      expect(result.stdout, equals('R1: r1_val, R2: r2_val, O1: o1, O2: o2\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with all params (named and positional mix)', () async {
      final result = await Process.run('p18_mix_hybrid_multi_params', [
        '-r',
        'r1_val',
        'r2_val',
        'o1_val',
        '-o',
        'o2_val',
      ]);
      expect(result.stdout, equals('R1: r1_val, R2: r2_val, O1: o1_val, O2: o2_val\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p18_mix_hybrid_multi_params', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p18_mix_hybrid_multi_params$reset: ${gray}Multiple mixed params$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}r1 (-r, --req1)$reset ${gray}Named required$reset\n'
            '    ${magenta}r2$reset ${gray}Positional required$reset\n'
            '  optional:\n'
            '    ${magenta}o1$reset ${gray}Positional optional$reset\n'
            '    ${bold}default$reset: "o1"\n'
            '    ${magenta}o2 (-o, --opt2)$reset ${gray}Named optional$reset\n'
            '    ${bold}default$reset: "o2"\n',
          ),
        );
      });
    }
  });
}
