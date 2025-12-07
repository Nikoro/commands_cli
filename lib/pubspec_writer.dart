import 'dart:io';

/// Returns true if the pubspec was modified
bool writePubspec(Directory projectDir, Iterable<String> newKeys) {
  final pubspecFile = File('${projectDir.path}/pubspec.yaml');

  // Collect existing executables if pubspec.yaml exists
  final existingKeys = <String>{};
  if (pubspecFile.existsSync()) {
    final lines = pubspecFile.readAsLinesSync();
    bool inExecutables = false;
    for (final line in lines) {
      if (line.trim() == 'executables:') {
        inExecutables = true;
        continue;
      }
      if (inExecutables) {
        if (line.trim().isEmpty || !line.contains(':')) break;
        final key = line.split(':').first.trim();
        if (key.isNotEmpty) existingKeys.add(key);
      }
    }
  }

  // Merge and sort
  final allKeys = {...existingKeys, ...newKeys}.toList()..sort();

  // Build executables block
  final executables = allKeys.map((k) => '  $k: $k').join('\n');

  // Write new pubspec.yaml (override fully)
  final content = '''
name: generated_commands
description: Generated commands from commands.yaml
version: 1.0.0
environment:
  sdk: ^3.0.0

dev_dependencies:
  commands_cli:
    git:
      url: https://github.com/Nikoro/commands_cli.git

executables:
$executables
''';

  // Check if content changed
  if (pubspecFile.existsSync() && pubspecFile.readAsStringSync() == content) {
    return false;
  }

  pubspecFile.writeAsStringSync(content);
  return true;
}
