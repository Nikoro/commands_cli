import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('p6_single_named_req_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p6_single_named_req_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    for (String param in ['-r', '--required']) {
      test('runs with param: $param', () async {
        final result = await Process.run('p6_single_named_req_no_comment', [param, 'value1']);
        expect(result.stdout, equals('Required: value1\n'));
        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p6_single_named_req_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p6_single_named_req_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset\n',
          ),
        );
      });
    }
  });

  group('p7_single_named_req_with_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p7_single_named_req_with_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}req$reset\n'));
    });

    for (String param in ['-r', '--required']) {
      test('runs with param: $param', () async {
        final result = await Process.run('p7_single_named_req_with_comment', [param, 'value1']);
        expect(result.stdout, equals('Required: value1\n'));
        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p7_single_named_req_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p7_single_named_req_with_comment$reset: ${gray}Script with one required named param$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req (-r, --required)$reset ${gray}Required parameter$reset\n',
          ),
        );
      });
    }
  });

  group('p8_multi_named_req_no_comment', () {
    test('fails without any params', () async {
      final result = await Process.run('p8_multi_named_req_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals('❌ Missing required named params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n'),
      );
    });

    test('fails with only one param', () async {
      final result = await Process.run('p8_multi_named_req_no_comment', ['-x', 'X1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named params: ${bold}${red}y$reset, ${bold}${red}z$reset\n'));
    });

    test('fails with only two params', () async {
      final result = await Process.run('p8_multi_named_req_no_comment', ['-x', 'X1', '-y', 'Y1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required named param: ${bold}${red}z$reset\n'));
    });

    test('runs with all three required params', () async {
      final result = await Process.run('p8_multi_named_req_no_comment', ['-x', 'X1', '-y', 'Y1', '-z', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with long flags', () async {
      final result = await Process.run('p8_multi_named_req_no_comment', [
        '--xray',
        'X2',
        '--yankee',
        'Y2',
        '--zulu',
        'Z2',
      ]);
      expect(result.stdout, equals('X: X2, Y: Y2, Z: Z2\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p8_multi_named_req_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p8_multi_named_req_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x (-x, --xray)$reset\n'
            '    ${magenta}y (-y, --yankee)$reset\n'
            '    ${magenta}z (-z, --zulu)$reset\n',
          ),
        );
      });
    }
  });

  group('p9_multi_named_req_partial_comment', () {
    test('fails without all required params', () async {
      final result = await Process.run('p9_multi_named_req_partial_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals('❌ Missing required named params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n'),
      );
    });

    test('runs with all params', () async {
      final result = await Process.run('p9_multi_named_req_partial_comment', ['-x', 'X1', '-y', 'Y1', '-z', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p9_multi_named_req_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p9_multi_named_req_partial_comment$reset: ${gray}Multiple required named params partial comments$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x (-x, --xray)$reset ${gray}X parameter$reset\n'
            '    ${magenta}y (-y, --yankee)$reset\n'
            '    ${magenta}z (-z, --zulu)$reset ${gray}Z parameter$reset\n',
          ),
        );
      });
    }
  });

  group('p10_multi_named_req_all_comment', () {
    test('fails without all required params', () async {
      final result = await Process.run('p10_multi_named_req_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals('❌ Missing required named params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n'),
      );
    });

    test('runs with all params using short flags', () async {
      final result = await Process.run('p10_multi_named_req_all_comment', ['-x', 'X1', '-y', 'Y1', '-z', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    test('runs with all params using long flags', () async {
      final result = await Process.run('p10_multi_named_req_all_comment', [
        '--xray',
        'X2',
        '--yankee',
        'Y2',
        '--zulu',
        'Z2',
      ]);
      expect(result.stdout, equals('X: X2, Y: Y2, Z: Z2\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p10_multi_named_req_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p10_multi_named_req_all_comment$reset: ${gray}Multiple required named params all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x (-x, --xray)$reset ${gray}X parameter$reset\n'
            '    ${magenta}y (-y, --yankee)$reset ${gray}Y parameter$reset\n'
            '    ${magenta}z (-z, --zulu)$reset ${gray}Z parameter$reset\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // LEVEL 3b: Positional Required Params Tests
  // ============================================================================

  group('p6_single_positional_req_no_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p6_single_positional_req_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with positional argument', () async {
      final result = await Process.run('p6_single_positional_req_no_comment', ['value1']);
      expect(result.stdout, equals('Required: value1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p6_single_positional_req_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p6_single_positional_req_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset\n',
          ),
        );
      });
    }
  });

  group('p7_single_positional_req_with_comment', () {
    test('fails without required param', () async {
      final result = await Process.run('p7_single_positional_req_with_comment', []);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}req$reset\n'));
    });

    test('runs with positional argument', () async {
      final result = await Process.run('p7_single_positional_req_with_comment', ['value1']);
      expect(result.stdout, equals('Required: value1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p7_single_positional_req_with_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p7_single_positional_req_with_comment$reset: ${gray}Script with one required positional param$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}req$reset ${gray}Required parameter$reset\n',
          ),
        );
      });
    }
  });

  group('p8_multi_positional_req_no_comment', () {
    test('fails without any params', () async {
      final result = await Process.run('p8_multi_positional_req_no_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals(
          '❌ Missing required positional params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n',
        ),
      );
    });

    test('fails with only one param', () async {
      final result = await Process.run('p8_multi_positional_req_no_comment', ['X1']);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals('❌ Missing required positional params: ${bold}${red}y$reset, ${bold}${red}z$reset\n'),
      );
    });

    test('fails with only two params', () async {
      final result = await Process.run('p8_multi_positional_req_no_comment', ['X1', 'Y1']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, equals('❌ Missing required positional param: ${bold}${red}z$reset\n'));
    });

    test('runs with all three required params', () async {
      final result = await Process.run('p8_multi_positional_req_no_comment', ['X1', 'Y1', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p8_multi_positional_req_no_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p8_multi_positional_req_no_comment$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x$reset\n'
            '    ${magenta}y$reset\n'
            '    ${magenta}z$reset\n',
          ),
        );
      });
    }
  });

  group('p9_multi_positional_req_partial_comment', () {
    test('fails without all required params', () async {
      final result = await Process.run('p9_multi_positional_req_partial_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals(
          '❌ Missing required positional params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n',
        ),
      );
    });

    test('runs with all params', () async {
      final result = await Process.run('p9_multi_positional_req_partial_comment', ['X1', 'Y1', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p9_multi_positional_req_partial_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p9_multi_positional_req_partial_comment$reset: ${gray}Multiple required positional params partial comments$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x$reset ${gray}X parameter$reset\n'
            '    ${magenta}y$reset\n'
            '    ${magenta}z$reset ${gray}Z parameter$reset\n',
          ),
        );
      });
    }
  });

  group('p10_multi_positional_req_all_comment', () {
    test('fails without all required params', () async {
      final result = await Process.run('p10_multi_positional_req_all_comment', []);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        equals(
          '❌ Missing required positional params: ${bold}${red}x$reset, ${bold}${red}y$reset, ${bold}${red}z$reset\n',
        ),
      );
    });

    test('runs with all positional params', () async {
      final result = await Process.run('p10_multi_positional_req_all_comment', ['X1', 'Y1', 'Z1']);
      expect(result.stdout, equals('X: X1, Y: Y1, Z: Z1\n'));
      expect(result.exitCode, equals(0));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help', () async {
        final result = await Process.run('p10_multi_positional_req_all_comment', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}p10_multi_positional_req_all_comment$reset: ${gray}Multiple required positional params all commented$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}x$reset ${gray}X parameter$reset\n'
            '    ${magenta}y$reset ${gray}Y parameter$reset\n'
            '    ${magenta}z$reset ${gray}Z parameter$reset\n',
          ),
        );
      });
    }
  });
}
