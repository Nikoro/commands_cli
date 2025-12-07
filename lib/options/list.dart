import 'dart:io';

import 'package:commands_cli/extensions.dart';
import 'package:commands_cli/generated_commands.dart';

void showList() {
  final commands = GeneratedCommands.binDir.existsSync()
      ? GeneratedCommands.binDir.listSync().map((e) => (e as File).onlyName).toList()
      : [];

  if (commands.isEmpty) {
    print('No commands installed');
  } else {
    print('Installed commands:');
    for (final cmd in commands) {
      print(' ⚡️ $cmd');
    }
  }
}
