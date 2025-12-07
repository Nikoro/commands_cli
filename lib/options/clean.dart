import 'dart:io';

import 'package:commands_cli/detached_watcher.dart';
import 'package:commands_cli/generated_commands.dart';

Future<void> handleClean() async {
  await killAllWatchers(silent: true);
  final result = await Process.run('dart', ['pub', 'global', 'deactivate', 'generated_commands'], runInShell: true);
  GeneratedCommands.delete();
  exit(result.exitCode);
}
