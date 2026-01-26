import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('commands', () {
    test('prints all commands with status indicators', () async {
      final result = await Process.run('commands', []);

      expect(
        result.stdout,
        equals(
            '✅ ${bold}${green}hello$reset:                                 ${gray}Prints "Hello World". Type "hello --help" to learn more.$reset\n'
            '✅ ${bold}${green}d$reset:                                     ${gray}Type "d --help" to learn more.$reset\n'
            '✅ ${bold}${green}make$reset:                                  ${gray}Type "make --help" to learn more.$reset\n'
            '⚠️  ${bold}${yellow}test$reset:                                  is a ${bold}${yellow}reserved$reset command. ${gray}In order to override it see: \x1B]8;;https://github.com/Nikoro/commands/blob/main/README.md#overriding-existing-commands\x1B\\README\x1B]8;;\x1B\\$reset\n'
            '❌ ${bold}${red}invalid!$reset:                              contains invalid characters\n'
            '❌ ${bold}${red}invalid_quoted_boolean$reset:                Parameter ${bold}${red}port$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[string]$reset\n'
            '❌ ${bold}${red}invalid_string_boolean$reset:                Parameter ${bold}${red}port$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[string]$reset\n'
            '❌ ${bold}${red}invalid_integer_boolean$reset:               Parameter ${bold}${red}port$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[integer]$reset\n'
            '❌ ${bold}${red}invalid_double_boolean$reset:                Parameter ${bold}${red}port$reset is declared as type ${gray}[boolean]$reset, but its default value is ${gray}[double]$reset\n'
            '❌ ${bold}${red}invalid_quoted_integer$reset:                Parameter ${bold}${red}port$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[string]$reset\n'
            '❌ ${bold}${red}invalid_double_integer$reset:                Parameter ${bold}${red}port$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[double]$reset\n'
            '❌ ${bold}${red}invalid_boolean_integer$reset:               Parameter ${bold}${red}port$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[boolean]$reset\n'
            '❌ ${bold}${red}invalid_quoted_double$reset:                 Parameter ${bold}${red}timeout$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[string]$reset\n'
            '❌ ${bold}${red}invalid_boolean_double$reset:                Parameter ${bold}${red}timeout$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[boolean]$reset\n'
            '❌ ${bold}${red}invalid_integer_double$reset:                Parameter ${bold}${red}timeout$reset is declared as type ${gray}[double]$reset, but its default value is ${gray}[integer]$reset\n'
            '❌ ${bold}${red}invalid_integer_string$reset:                Parameter ${bold}${red}code$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[integer]$reset\n'
            '❌ ${bold}${red}invalid_double_string$reset:                 Parameter ${bold}${red}version$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[double]$reset\n'
            '❌ ${bold}${red}invalid_boolean_string$reset:                Parameter ${bold}${red}timeout$reset is declared as type ${gray}[string]$reset, but its default value is ${gray}[boolean]$reset\n'
            '❌ ${bold}${red}invalid_script_and_switch$reset:             Cannot use both ${bold}${red}script$reset and ${bold}${red}switch$reset at the same time\n'
            '❌ ${bold}${red}invalid_typed_enum_integer_string$reset:     Parameter ${bold}${red}platform$reset expects an ${gray}[integer]$reset\n'
            '   Got: text ${gray}[string]$reset in values\n'
            '❌ ${bold}${red}invalid_typed_enum_int_default_string$reset: Parameter ${bold}${red}platform$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[string]$reset\n'
            '❌ ${bold}${red}invalid_typed_enum_integer_double$reset:     Parameter ${bold}${red}platform$reset expects an ${gray}[integer]$reset\n'
            '   Got: 3.3 ${gray}[double]$reset in values\n'
            '❌ ${bold}${red}invalid_typed_enum_int_default_double$reset: Parameter ${bold}${red}platform$reset is declared as type ${gray}[integer]$reset, but its default value is ${gray}[double]$reset\n'),
      );

      expect(result.exitCode, equals(0));
    }, timeout: Timeout(Duration(minutes: 2)));

    for (String flag in ['version', '-v', '--version']) {
      test('$flag flag prints version', () async {
        final result = await Process.run('commands', [flag]);

        expect(result.stdout, contains('commands_cli version:'));
        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['list', '-l', '--list']) {
      test('$flag flag prints installed commands', () async {
        final result = await Process.run('commands', [flag]);

        final output = result.stdout as String;

        expect(output, contains('Installed commands:'));
        expect(output, contains('⚡️'));

        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['help', '-h', '--help']) {
      test('$flag flag prints help information', () async {
        final result = await Process.run('commands', [flag]);

        expect(
          result.stdout,
          equals(
            '${bold}Commands - CLI tool for managing custom commands$reset\n'
            '\n'
            '${bold}Usage:$reset commands [option]\n'
            '\n'
            '${bold}Options:$reset\n'
            '  ${blue}help, --help, -h$reset                        ${gray}- Display this help message$reset\n'
            '  ${blue}version, --version, -v$reset                  ${gray}- Show the current version of commands$reset\n'
            '  ${blue}clean, --clean, -c$reset                      ${gray}- Remove all generated commands$reset\n'
            '  ${blue}create [--empty|-e]$reset                     ${gray}- Create a new commands.yaml file (use --empty or -e for empty file)$reset\n'
            '  ${blue}deactivate, --deactivate, -d [command]$reset  ${gray}- Deactivate commands package or specific commands$reset\n'
            '  ${blue}list, --list, -l$reset                        ${gray}- List all installed commands$reset\n'
            '  ${blue}regenerate, --regenerate, -r$reset            ${gray}- Clean and regenerate all previously generated commands$reset\n'
            '  ${blue}update, --update, -u$reset                    ${gray}- Update commands package to the latest version$reset\n'
            '  ${blue}watch, --watch, -w$reset                      ${gray}- Watch commands.yaml for changes and auto-reload$reset\n'
            '  ${blue}--watch-detached, -wd$reset                   ${gray}- Start watching in detached mode (background process)$reset\n'
            '  ${blue}--watch-kill, -wk$reset                       ${gray}- Kill the detached watcher process$reset\n'
            '  ${blue}--watch-kill-all, -wka$reset                  ${gray}- Kill all detached watcher processes$reset\n'
            '  ${blue}--exit-error, -ee$reset                       ${gray}- Exit with code 1 immediately on error$reset\n'
            '  ${blue}--exit-warning, -ew$reset                     ${gray}- Exit with code 1 immediately on error or warning$reset\n'
            '  ${blue}--silent, -s$reset                            ${gray}- Suppress all output (combine with exit options to show only errors/warnings)$reset\n'
            '\n'
            '${bold}Default behavior:$reset\n'
            '  Running ${blue}commands$reset without arguments will load and activate\n'
            '  all commands from commands.yaml in the current directory\n'
            '\n'
            '${bold}Examples:$reset\n'
            '  ${blue}commands --silent$reset            ${gray}- Activate commands without any output$reset\n'
            '  ${blue}commands -s -ee$reset              ${gray}- Silent mode, exit on error (shows only errors)$reset\n'
            '  ${blue}commands --exit-warning$reset      ${gray}- Exit with error code if warnings occur$reset\n',
          ),
        );

        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['update', '-u', '--update']) {
      test('$flag flag runs update command', () async {
        final result = await Process.run('commands', [flag]);

        final output = result.stdout as String;

        // Should show updating message (either from git or pub.dev)
        expect(
          output,
          anyOf([
            contains('${bold}Updating global commands_cli package...$reset\n'),
            contains('${bold}Updating global commands_cli package from git...$reset\n'),
          ]),
        );

        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['--silent', '-s']) {
      test('$flag suppresses all output when no errors/warnings to report', () async {
        final result = await Process.run('commands', [flag]);

        final output = result.stdout as String;

        expect(output, isEmpty);
        expect(result.exitCode, equals(0));
      });
    }

    for (String flag in ['--exit-error', '-ee']) {
      test('$flag exits with code 1 when errors exist', () async {
        final result = await Process.run('commands', [flag]);

        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should still show the errors
        expect(output, allOf(contains('❌'), contains('$red')));
      });
    }

    for (String flag in ['--exit-warning', '-ew']) {
      test('$flag exits with code 1 when warnings exist', () async {
        final result = await Process.run('commands', [flag]);

        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should show warnings and errors
        expect(output, allOf(contains('❌'), contains('$red'), contains('⚠️'), contains('$yellow')));
      });
    }

    for (List<String> combo in [
      ['--silent', '--exit-error'],
      ['--silent', '-ee'],
      ['-s', '-ee'],
      ['-s', '--exit-error']
    ]) {
      test('${combo.join(' ')} shows only errors and exits', () async {
        final result = await Process.run('commands', combo);

        final output = result.stdout as String;

        // Should NOT contain success messages
        expect(output, isNot(allOf(contains('✅'), contains('$green'))));

        // Should NOT contain warnings (silent mode without --exit-warning)
        expect(output, isNot(allOf(contains('⚠️'), contains('$yellow'))));

        // Should show errors
        expect(output, allOf(contains('❌'), contains('$red')));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });
    }
    for (List<String> combo in [
      ['--silent', '--exit-warning'],
      ['--silent', '-ew'],
      ['-s', '-ew'],
      ['-s', '--exit-warning']
    ]) {
      test('${combo.join(' ')} shows errors and warnings and exits', () async {
        final result = await Process.run('commands', combo);

        final output = result.stdout as String;

        // Should NOT contain success messages
        expect(output, isNot(allOf(contains('✅'), contains('$green'))));

        // Should show warnings
        expect(output, allOf(contains('⚠️'), contains('$yellow')));

        // Should show errors
        expect(output, allOf(contains('❌'), contains('$red')));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });
    }
  });
}
