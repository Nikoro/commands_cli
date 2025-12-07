import 'dart:io';

import 'package:commands_cli/colors.dart';

Future<void> handleUpdate() async {
  final isGlobalExecution = Platform.script.toFilePath().contains('.pub-cache/global_packages');

  final ProcessResult result;

  if (isGlobalExecution) {
    // Update global installation
    print('${bold}Updating global commands_cli package...$reset\n');
    result = await Process.run(
      'dart',
      ['pub', 'global', 'activate', 'commands_cli'],
      runInShell: true,
    );
  } else {
    // Update local dependency
    print('${bold}Updating local commands_cli dependency...$reset\n');
    result = await Process.run(
      'dart',
      ['pub', 'upgrade', 'commands_cli'],
      runInShell: true,
    );
  }

  if (result.exitCode == 0) {
    final output = result.stdout.toString();
    print(output);

    // Check if already up to date
    if (output.contains('is already active') || output.contains('already using')) {
      print('$bold$blue Already up to date!$reset');
    } else {
      print('$bold$green✓ Successfully updated!$reset');
    }
  } else {
    print('$red✗ Update failed:$reset');
    print(result.stderr);
    exit(1);
  }
}
