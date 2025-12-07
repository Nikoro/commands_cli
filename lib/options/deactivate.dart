import 'dart:io';

import 'package:commands_cli/generated_commands.dart';

Future<void> handleDeactivate(List<String> args) async {
  final extraArgs = args.where((a) => !['deactivate', '--deactivate', '-d'].contains(a)).toList();

  if (extraArgs.isEmpty) {
    GeneratedCommands.delete();
    final process = await Process.start(
      'dart',
      ['pub', 'global', 'deactivate', 'commands'],
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
    exit(await process.exitCode);
  } else {
    GeneratedCommands.delete(extraArgs);
  }
}
