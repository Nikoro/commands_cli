import 'dart:io';

class ReservedCommands {
  ReservedCommands._();
  static final _home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  static final reservedFile = File('$_home/.generated_commands/reserved_commands.txt');
  static final generatedPackageDir = Directory('$_home/.generated_commands');
  static final pubCacheBin = Directory('$_home/.pub-cache/bin');

  static Set<String> load() {
    if (!reservedFile.existsSync()) return {};
    return reservedFile.readAsLinesSync().map((line) => line.trim()).where((line) => line.isNotEmpty).toSet();
  }

  static void save(Set<String> commands) {
    reservedFile.createSync(recursive: true);
    reservedFile.writeAsStringSync('${commands.join('\n')}\n');
  }

  static void add(String command) {
    final commands = load();
    if (commands.add(command)) {
      save(commands);
    }
  }

  static void removeFromCache(String command) {
    final commands = load();
    if (commands.remove(command)) {
      save(commands);
    }
  }

  static void clearCacheFor(Iterable<String> commands) {
    final cached = load();
    bool modified = false;
    for (final cmd in commands) {
      if (cached.remove(cmd)) {
        modified = true;
      }
    }
    if (modified) save(cached);
  }

  static bool isCached(String command) => load().contains(command);

  static Set<String> _generatedExecutables() {
    final pubspecFile = File('${generatedPackageDir.path}/pubspec.yaml');
    if (!pubspecFile.existsSync()) return {};
    final lines = pubspecFile.readAsLinesSync();
    final executables = <String>{};
    bool inExecutables = false;
    for (var line in lines) {
      line = line.trim();
      if (line == 'executables:') {
        inExecutables = true;
        continue;
      }
      if (inExecutables) {
        if (line.isEmpty || !line.contains(':')) break;
        final key = line.split(':').first.trim();
        if (key.isNotEmpty) executables.add(key);
      }
    }
    return executables;
  }

  static Future<bool> isReserved(String name, {Set<String>? excludeFromGenerated}) async {
    if (isCached(name)) return true;

    final reserved = await _systemCheck(name);

    final generatedExecutables = _generatedExecutables();
    // Temporarily exclude commands being checked from generated list to detect conflicts
    if (excludeFromGenerated != null) {
      generatedExecutables.removeAll(excludeFromGenerated);
    }

    final binExecutables = <String>{};
    if (pubCacheBin.existsSync()) {
      for (final f in pubCacheBin.listSync()) {
        if (f is File) {
          final baseName = f.uri.pathSegments.last.split('.').first;
          if (!generatedExecutables.contains(baseName)) {
            binExecutables.add(baseName);
          }
        }
      }
    }

    // Also exclude commands being checked from bin executables check
    if (excludeFromGenerated != null) {
      binExecutables.removeAll(excludeFromGenerated);
    }

    final isReservedFinal = reserved || binExecutables.contains(name);

    if (isReservedFinal) add(name);

    return isReservedFinal;
  }

  static Future<bool> _systemCheck(String name) async {
    if (Platform.isWindows) {
      final env = Platform.environment;
      final exts = env['PATHEXT']?.split(';') ?? ['.exe', '.bat', '.cmd'];
      final paths = (env['PATH'] ?? '').split(Platform.pathSeparator);

      for (final dir in paths) {
        for (final ext in exts) {
          final candidate = File('$dir${Platform.pathSeparator}$name$ext');
          if (candidate.existsSync()) return true;
        }
      }
      return false;
    } else {
      final shell = Platform.environment['SHELL'] ?? 'sh';
      final result = await Process.run(shell, ['-c', 'type $name'], runInShell: true);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        if (['builtin', 'keyword', 'is'].any(output.contains) && !output.contains('.pub-cache')) {
          return true;
        }
      }
      return false;
    }
  }
}
