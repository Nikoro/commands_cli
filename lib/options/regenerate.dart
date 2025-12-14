import 'dart:io';

import 'package:commands_cli/detached_watcher.dart';
import 'package:commands_cli/extensions.dart';
import 'package:commands_cli/generated_commands.dart';

Future<void> handleRegenerate() async {
  // Step 1: Get list of currently generated commands before cleaning
  final commands = GeneratedCommands.binDir.existsSync()
      ? GeneratedCommands.binDir.listSync().map((e) => (e as File).onlyName).toList()
      : [];

  if (commands.isEmpty) {
    print('⚠️  No commands to regenerate');
    exit(0);
  }

  print('🔄 Regenerating ${commands.length} command${commands.length > 1 ? 's' : ''}...');

  // Step 2: Perform clean (same as handleClean)
  await killAllWatchers(silent: true);
  await Process.run('dart', ['pub', 'global', 'deactivate', 'generated_commands'], runInShell: true);
  GeneratedCommands.delete();

  // Step 3: Reactivate the same commands by running 'commands' with the commands
  // The activation process in commands.dart will be triggered by re-running the main binary
  final result = await Process.run('commands', [], runInShell: true);

  if (result.exitCode == 0) {
    print('✅ Successfully regenerated all commands');
  } else {
    print('❌ Failed to regenerate commands');
    print(result.stderr);
  }

  exit(result.exitCode);
}
