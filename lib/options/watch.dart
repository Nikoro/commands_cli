import 'dart:io';

import 'package:commands_cli/yaml_file.dart';
import 'package:commands_cli/yaml_watcher.dart';

Future<void> handleWatch() async {
  if (!hasYamlFile) {
    print('❌ No commands.yaml found');
    exit(1);
  }
  print('Watching commands.yaml for changes...');
  await watchCommandsYaml();
}
