import 'dart:io';

import 'package:commands_cli/detached_watcher.dart';
import 'package:commands_cli/yaml_file.dart';

Future<void> handleWatchKill() async {
  if (!hasYamlFile) {
    print('❌ No commands.yaml found');
    exit(1);
  }
  await killDetachedWatcher(yamlFile);
  print('You can continue typing commands.');
}
