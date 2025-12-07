import 'dart:io';

import 'package:commands_cli/colors.dart';

Future<void> createCommandsYaml(List<String> args) async {
  final fileYaml = File('commands.yaml');
  final fileYml = File('commands.yml');

  if (await fileYaml.exists() || await fileYml.exists()) {
    print('⚠️  ${yellow}commands.yaml already exists$reset');
    return;
  }

  final empty = ['--empty', '-e'].any(args.contains);

  await fileYaml.writeAsString(
    empty
        ? ''
        : '''
hello: ## Prints "Hello World"
  script: echo "Hello World"
''',
  );

  print('✅ ${green}commands.yaml successfully created$reset');
}
