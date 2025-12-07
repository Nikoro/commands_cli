import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('p1_single_named_opt_no_comment', () {
    test('runs with default value', () async {
      final result = await Process.run('p1_single_named_opt_no_comment', []);
      expect(result.stdout, equals('Value: default1\n'));
    });

    for (String param in ['-v', '--value', 'va']) {
      test('accepts param: $param', () async {
        final result = await Process.run('p1_single_named_opt_no_comment', [param, 'custom']);
        expect(result.stdout, equals('Value: custom\n'));
      });
    }

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p1_single_named_opt_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p1_single_named_opt_no_comment$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}val (-v, --value, va)$reset\n'
            '    ${bold}default$reset: "default1"\n',
          ),
        );
      });
    }
  });

  group('p2_single_named_opt_with_comment', () {
    test('runs with default value', () async {
      final result = await Process.run('p2_single_named_opt_with_comment', []);
      expect(result.stdout, equals('Value: default2\n'));
    });

    for (String param in ['-v', '--value', 'va']) {
      test('accepts param: $param', () async {
        final result = await Process.run('p2_single_named_opt_with_comment', [param, 'custom']);
        expect(result.stdout, equals('Value: custom\n'));
      });
    }

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p2_single_named_opt_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p2_single_named_opt_with_comment$reset: ${gray}Script with one optional named param$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}val (va, --value, -v)$reset ${gray}The value parameter$reset\n'
            '    ${bold}default$reset: "default2"\n',
          ),
        );
      });
    }
  });

  group('p3_multi_named_opt_no_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p3_multi_named_opt_no_comment', []);
      expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
    });

    test('accepts -a flag', () async {
      final result = await Process.run('p3_multi_named_opt_no_comment', ['-a', 'custom']);
      expect(result.stdout, equals('A: custom, B: B1, C: C1\n'));
    });

    test('accepts multiple flags', () async {
      final result = await Process.run('p3_multi_named_opt_no_comment', ['-a', 'X', '-b', 'Y']);
      expect(result.stdout, equals('A: X, B: Y, C: C1\n'));
    });

    test('accepts all flags with long names', () async {
      final result = await Process.run('p3_multi_named_opt_no_comment', [
        '--alpha',
        'X',
        '--beta',
        'Y',
        '--charlie',
        'Z',
      ]);
      expect(result.stdout, equals('A: X, B: Y, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p3_multi_named_opt_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p3_multi_named_opt_no_comment$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a (-a, --alpha)$reset\n'
            '    ${bold}default$reset: "A1"\n'
            '    ${magenta}b (--beta, -b)$reset\n'
            '    ${bold}default$reset: "B1"\n'
            '    ${magenta}c (-c, --charlie)$reset\n'
            '    ${bold}default$reset: "C1"\n',
          ),
        );
      });
    }
  });

  group('p4_multi_named_opt_partial_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p4_multi_named_opt_partial_comment', []);
      expect(result.stdout, equals('A: A2, B: B2, C: C2\n'));
    });

    test('accepts flags', () async {
      final result = await Process.run('p4_multi_named_opt_partial_comment', ['-a', 'X', '-c', 'Z']);
      expect(result.stdout, equals('A: X, B: B2, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p4_multi_named_opt_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p4_multi_named_opt_partial_comment$reset: ${gray}Multiple optional named params with some comments$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a (-a, --alpha)$reset ${gray}Alpha parameter$reset\n'
            '    ${bold}default$reset: "A2"\n'
            '    ${magenta}b (-b, --beta)$reset\n'
            '    ${bold}default$reset: "B2"\n'
            '    ${magenta}c (-c, --charlie)$reset ${gray}Charlie parameter$reset\n'
            '    ${bold}default$reset: "C2"\n',
          ),
        );
      });
    }
  });

  group('p5_multi_named_opt_all_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p5_multi_named_opt_all_comment', []);
      expect(result.stdout, equals('A: A3, B: B3, C: C3\n'));
    });

    test('accepts all flags', () async {
      final result = await Process.run('p5_multi_named_opt_all_comment', [
        '--alpha',
        'X',
        '--beta',
        'Y',
        '--charlie',
        'Z',
      ]);
      expect(result.stdout, equals('A: X, B: Y, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p5_multi_named_opt_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p5_multi_named_opt_all_comment$reset: ${gray}Multiple optional named params all commented$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a (-a, --alpha)$reset ${gray}Alpha parameter$reset\n'
            '    ${bold}default$reset: "A3"\n'
            '    ${magenta}b (-b, --beta)$reset ${gray}Beta parameter$reset\n'
            '    ${bold}default$reset: "B3"\n'
            '    ${magenta}c (-c, --charlie)$reset ${gray}Charlie parameter$reset\n'
            '    ${bold}default$reset: "C3"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 2b: Positional Optional Params Tests
  // ============================================================================

  group('p1_single_positional_opt_no_comment', () {
    test('runs with default value', () async {
      final result = await Process.run('p1_single_positional_opt_no_comment', []);
      expect(result.stdout, equals('Value: default1\n'));
    });

    test('accepts positional argument', () async {
      final result = await Process.run('p1_single_positional_opt_no_comment', ['custom']);
      expect(result.stdout, equals('Value: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p1_single_positional_opt_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p1_single_positional_opt_no_comment$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}val$reset\n'
            '    ${bold}default$reset: "default1"\n',
          ),
        );
      });
    }
  });

  group('p2_single_positional_opt_with_comment', () {
    test('runs with default value', () async {
      final result = await Process.run('p2_single_positional_opt_with_comment', []);
      expect(result.stdout, equals('Value: default2\n'));
    });

    test('accepts positional argument', () async {
      final result = await Process.run('p2_single_positional_opt_with_comment', ['custom']);
      expect(result.stdout, equals('Value: custom\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p2_single_positional_opt_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p2_single_positional_opt_with_comment$reset: ${gray}Script with one optional positional param$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}val$reset ${gray}The value parameter$reset\n'
            '    ${bold}default$reset: "default2"\n',
          ),
        );
      });
    }
  });

  group('p3_multi_positional_opt_no_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p3_multi_positional_opt_no_comment', []);
      expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
    });

    test('accepts single positional argument', () async {
      final result = await Process.run('p3_multi_positional_opt_no_comment', ['custom']);
      expect(result.stdout, equals('A: custom, B: B1, C: C1\n'));
    });

    test('accepts multiple positional arguments', () async {
      final result = await Process.run('p3_multi_positional_opt_no_comment', ['X', 'Y']);
      expect(result.stdout, equals('A: X, B: Y, C: C1\n'));
    });

    test('accepts all positional arguments', () async {
      final result = await Process.run('p3_multi_positional_opt_no_comment', ['X', 'Y', 'Z']);
      expect(result.stdout, equals('A: X, B: Y, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p3_multi_positional_opt_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p3_multi_positional_opt_no_comment$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a$reset\n'
            '    ${bold}default$reset: "A1"\n'
            '    ${magenta}b$reset\n'
            '    ${bold}default$reset: "B1"\n'
            '    ${magenta}c$reset\n'
            '    ${bold}default$reset: "C1"\n',
          ),
        );
      });
    }
  });

  group('p4_multi_positional_opt_partial_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p4_multi_positional_opt_partial_comment', []);
      expect(result.stdout, equals('A: A2, B: B2, C: C2\n'));
    });

    test('accepts positional arguments', () async {
      final result = await Process.run('p4_multi_positional_opt_partial_comment', ['X', 'Y', 'Z']);
      expect(result.stdout, equals('A: X, B: Y, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p4_multi_positional_opt_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p4_multi_positional_opt_partial_comment$reset: ${gray}Multiple optional positional params with some comments$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a$reset ${gray}Alpha parameter$reset\n'
            '    ${bold}default$reset: "A2"\n'
            '    ${magenta}b$reset\n'
            '    ${bold}default$reset: "B2"\n'
            '    ${magenta}c$reset ${gray}Charlie parameter$reset\n'
            '    ${bold}default$reset: "C2"\n',
          ),
        );
      });
    }
  });

  group('p5_multi_positional_opt_all_comment', () {
    test('runs with all defaults', () async {
      final result = await Process.run('p5_multi_positional_opt_all_comment', []);
      expect(result.stdout, equals('A: A3, B: B3, C: C3\n'));
    });

    test('accepts all positional arguments', () async {
      final result = await Process.run('p5_multi_positional_opt_all_comment', ['X', 'Y', 'Z']);
      expect(result.stdout, equals('A: X, B: Y, C: Z\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p5_multi_positional_opt_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p5_multi_positional_opt_all_comment$reset: ${gray}Multiple optional positional params all commented$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}a$reset ${gray}Alpha parameter$reset\n'
            '    ${bold}default$reset: "A3"\n'
            '    ${magenta}b$reset ${gray}Beta parameter$reset\n'
            '    ${bold}default$reset: "B3"\n'
            '    ${magenta}c$reset ${gray}Charlie parameter$reset\n'
            '    ${bold}default$reset: "C3"\n',
          ),
        );
      });
    }
  });
}
