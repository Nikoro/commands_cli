import 'dart:io';

String _hashForYaml(File yamlFile) => yamlFile.absolute.path.hashCode.toString();

/// Get all running watcher PIDs for this YAML
Future<List<int>> _getWatcherPids(File yamlFile) async {
  final hash = _hashForYaml(yamlFile);
  final ps = await Process.run('ps', ['aux']);
  if (ps.exitCode != 0) return [];

  final lines = (ps.stdout as String).split('\n');
  final pids = <int>[];

  for (final line in lines) {
    if (line.contains('commands') && line.contains('watch') && line.contains(hash) && !line.contains('grep')) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        final pid = int.tryParse(parts[1]);
        if (pid != null) pids.add(pid);
      }
    }
  }

  return pids;
}

/// Start a detached watcher for the given YAML file
Future<void> startDetachedWatcher(File yamlFile) async {
  final hash = _hashForYaml(yamlFile);

  final existingPids = await _getWatcherPids(yamlFile);
  if (existingPids.isNotEmpty) {
    print('Watcher already running for ${yamlFile.path} (PIDs: ${existingPids.join(',')})');
    return;
  }

  // Start the detached watcher with the hash as identifier
  await Process.start('commands', ['--watch', '--watch-id', hash], mode: ProcessStartMode.detached);

  print('Detached watcher started for ${yamlFile.path}');
}

/// kill all watchers for the given YAML file
Future<void> killDetachedWatcher(File yamlFile) async {
  final pids = await _getWatcherPids(yamlFile);
  if (pids.isEmpty) {
    print('No watcher running for ${yamlFile.path}');
    return;
  }

  for (final pid in pids) {
    try {
      Process.killPid(pid);
      print('💀 Killed watcher PID: $pid');
    } catch (_) {
      print('❌ Failed to kill watcher PID: $pid');
    }
  }
}

Future<void> killAllWatchers({bool silent = false}) async {
  final ps = await Process.run('ps', ['aux']);

  if (ps.exitCode != 0) {
    if (!silent) print('❌ Failed to run ps command.');
    return;
  }

  final lines = (ps.stdout as String).split('\n');

  for (final line in lines) {
    if (line.contains('commands') && line.contains('watch') && !line.contains('grep')) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        final pid = int.tryParse(parts[1]);
        if (pid != null) {
          try {
            Process.killPid(pid);
            if (!silent) print('💀 Killed commands watcher PID: $pid');
          } catch (e) {
            if (!silent) print('❌ Failed to kill PID $pid: $e');
          }
        }
      }
    }
  }
}
