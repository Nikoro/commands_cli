import 'dart:io';

import 'package:commands_cli/colors.dart';

Future<void> showVersion() async {
  final version = await _getVersion();
  print('commands version: $bold$blue$version$reset');
}

Future<String?> _getVersion() async {
  final isGlobalExecution = Platform.script.toFilePath().contains('.pub-cache/global_packages');

  if (isGlobalExecution) {
    final globalResult = await Process.run('dart', ['pub', 'global', 'list'], runInShell: true);

    if (globalResult.exitCode == 0) {
      final output = globalResult.stdout.toString();
      final match = RegExp(r'^commands\s+([\d\.]+)', multiLine: true).firstMatch(output);
      if (match != null) return match.group(1);
    }
  }

  final lockFile = File('pubspec.lock');
  if (lockFile.existsSync()) {
    final version = _parseVersionFromLock(lockFile, 'commands');
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
