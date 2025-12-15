import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:commands_cli/version_checker.dart';

Future<void> showVersion() async {
  final version = await _getVersion();
  print('commands_cli version: $bold$blue$version$reset');

  // Check for updates
  if (version != null) {
    final updateCheck = await checkForUpdate(version);

    if (updateCheck != null && updateCheck.hasNewerVersion) {
      print('${orange}Update available!$reset $blue$version$reset → $blue${updateCheck.latestVersion}$reset');

      if (updateCheck.changelogUrl != null) {
        final url = updateCheck.changelogUrl!;
        // OSC 8 hyperlink: \x1B]8;;URL\x1B\\TEXT\x1B]8;;\x1B\\
        final clickableLink = '\x1B]8;;$url\x1B\\$blue$url$reset\x1B]8;;\x1B\\';
        print('${orange}Changelog:$reset $clickableLink');
      }

      print('Run ${blue}commands update$reset to update');
    }
  }
}

Future<String?> _getVersion() async {
  final isGlobalExecution = Platform.script.toFilePath().contains('.pub-cache/global_packages');

  if (isGlobalExecution) {
    final globalResult = await Process.run('dart', ['pub', 'global', 'list'], runInShell: true);

    if (globalResult.exitCode == 0) {
      final output = globalResult.stdout.toString();
      final match = RegExp(r'^commands_cli\s+([\d\.]+)', multiLine: true).firstMatch(output);
      if (match != null) return match.group(1);
    }
  }

  final lockFile = File('pubspec.lock');
  if (lockFile.existsSync()) {
    final version = _parseVersionFromLock(lockFile, 'commands_cli');
    if (version != null) return version;
  }

  return null;
}

String? _parseVersionFromLock(File lockFile, String packageName) {
  final lines = lockFile.readAsLinesSync();
  bool inBlock = false;

  for (var line in lines) {
    line = line.trimRight();

    if (line.trim() == '$packageName:') {
      inBlock = true;
      continue;
    }

    if (inBlock) {
      if (!line.startsWith('  ')) break;
      final match = RegExp(r'version:\s*"([\d\.]+)"').firstMatch(line.trim());
      if (match != null) {
        return match.group(1);
      }
    }
  }

  return null;
}
