import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}, D: {delta}"
          params:
            required:
              - alpha: '-a, --alpha'
                default: "A1"
              - beta:
                default: "B1"
            optional:
              - charlie: '-c, --charlie'
                default: "C1"
              - delta:
                default: "D1"
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: B1, C: C1, D: D1"', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stdout, equals('A: x, B: B1, C: C1, D: D1\n'));
        });

        test('prints "A: x, B: y, C: C1, D: D1"', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y']);
          expect(result.stdout, equals('A: x, B: y, C: C1, D: D1\n'));
        });

        test('prints "A: x, B: y, C: C1, D: z"', () async {
          final result = await Process.run('hello', [alpha, 'x', 'y', 'z']);
          expect(result.stdout, equals('A: x, B: y, C: C1, D: z\n'));
        });

        for (String charlie in ['-c', '--charlie']) {
          test('prints "A: x, B: y, C: z, D: D1"', () async {
            final result = await Process.run('hello', [alpha, 'x', 'y', charlie, 'z']);
            expect(result.stdout, equals('A: x, B: y, C: z, D: D1\n'));
          });

          test('prints "A: x, B: y, C: z, D: a"', () async {
            final result = await Process.run('hello', [alpha, 'x', 'y', charlie, 'z', 'a']);
            expect(result.stdout, equals('A: x, B: y, C: z, D: a\n'));
          });
        }
      }

      test('prints "A: A1, B: y, C: C1, D: D1"', () async {
        final result = await Process.run('hello', ['y']);
        expect(result.stdout, equals('A: A1, B: y, C: C1, D: D1\n'));
      });

      test('prints "A: A1, B: B1, C: C1, D: D1"', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: A1, B: B1, C: C1, D: D1\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset
    ${bold}default$reset: $bold${orange}"A1"$reset
    ${magenta}beta$reset
    ${bold}default$reset: $bold${orange}"B1"$reset
  optional:
    ${magenta}charlie (-c, --charlie)$reset
    ${bold}default$reset: $bold${orange}"C1"$reset
    ${magenta}delta$reset
    ${bold}default$reset: $bold${orange}"D1"$reset
'''));
        });
      }
    },
  );
}
