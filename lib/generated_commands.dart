import 'dart:io';

import 'package:commands_cli/colors.dart';

abstract class GeneratedCommands {
  GeneratedCommands._();
  static final _home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';

  static final dir = Directory('$_home/.generated_commands');
  static final binDir = Directory('$_home/.generated_commands/bin');
  static final pubCacheBinDir = Directory('$_home/.pub-cache/bin');

  static void ensureExists() => binDir.createSync(recursive: true);

  /// Deletes all or specific command keywords.
  /// - If no [commands] provided, delete everything.
  /// - If list of [commands] provided, only delete those files.
  static void delete([List<String>? commands]) {
    if (commands == null || commands.isEmpty) {
      // No commands provided -> delete everything
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      print('✅ ${green}All generated commands removed$reset');
      return;
    }

    // Delete specific commands
    for (final keyword in commands) {
      final pubCacheFile = File('${pubCacheBinDir.path}/$keyword');
      if (pubCacheFile.existsSync()) {
        pubCacheFile.deleteSync();
      }

      final file = File('${binDir.path}/$keyword.dart');
      if (file.existsSync()) {
        file.deleteSync();
        print('✅ ${green}Removed command: $keyword$reset');
      } else {
        print('⚠️  ${yellow}Command not found: $keyword$reset');
      }
    }
  }
}
