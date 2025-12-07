import 'dart:io';

import 'package:commands_cli/extensions.dart';

Future<void> watchCommandsYaml() async {
  final file = ['commands.yaml', 'commands.yml'].map((f) => File(f)).firstWhere(
    (f) => f.existsSync(),
    orElse: () {
      print('❌ No commands.yaml found');
      exit(1);
    },
  );

  file.watch(events: FileSystemEvent.modify).listen((event) async {
    print('Detected changes in ${file.name}, running commands...');
    final process = await Process.start('commands', [], mode: ProcessStartMode.inheritStdio, runInShell: true);
    await process.exitCode;
  });
}
