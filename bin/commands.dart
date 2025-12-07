import 'dart:io';

import 'package:commands_cli/activator.dart';
import 'package:commands_cli/bin_writer.dart';
import 'package:commands_cli/colors.dart';
import 'package:commands_cli/command_validator.dart';
import 'package:commands_cli/extensions.dart';
import 'package:commands_cli/link.dart';
import 'package:commands_cli/options/options.dart';
import 'package:commands_cli/yaml_file.dart';
import 'package:commands_cli/generated_commands.dart';
import 'package:commands_cli/pubspec_writer.dart';
import 'package:commands_cli/reserved_commands.dart';
import 'package:commands_cli/shell_cache_flusher.dart';
import 'package:commands_cli/commands_loader.dart';

Future<void> main(List<String> args) async {
  if (args.containsAny(['help', '--help', '-h'])) {
    showHelp();
    return;
  }

  if (args.containsAny(['version', '--version', '-v'])) {
    await showVersion();
    return;
  }

  if (args.containsAny(['list', '--list', '-l'])) {
    showList();
    return;
  }

  if (args.contains('create')) {
    await createCommandsYaml(args);
    return;
  }

  if (args.containsAnyCombo([
    ['--watch-detached'],
    ['-wd'],
    ['-w-d'],
    ['--watch', '--detached'],
    ['-w', '-d'],
    ['-w', '--detached'],
    ['--watch', '-d'],
  ])) {
    await handleWatchDetached();
    return;
  }

  if (args.containsAnyCombo([
    ['--watch-kill'],
    ['-wk'],
    ['-w-k'],
    ['--watch', '--kill'],
    ['-w', '-k'],
    ['-w', '--kill'],
    ['--watch', '-k'],
  ])) {
    await handleWatchKill();
    return;
  }

  if (args.containsAnyCombo([
    ['--watch-kill-all'],
    ['-wka'],
    ['-w-k-a'],
    ['--watch', '--kill', '--all'],
    ['-w', '-k', '-a'],
    ['-w', '-k', '--all'],
    ['-w', '--kill', '--all'],
    ['-w', '--kill', '-a'],
    ['--watch', '-k', '--all'],
    ['--watch', '-k', '-a'],
    ['--watch', '--kill', '-a'],
  ])) {
    await handleWatchKillAll();
    return;
  }

  if (args.containsAny(['watch', '--watch', '-w'])) {
    await handleWatch();
    return;
  }

  if (args.containsAny(['deactivate', '--deactivate', '-d'])) {
    await handleDeactivate(args);
    return;
  }

  if (args.containsAny(['clean', '--clean', '-c'])) {
    await handleClean();
    return;
  }

  if (!hasYamlFile) {
    print('❌ No commands.yaml found');
    exit(1);
  }

  final yamlContent = loadCommandsFrom(yamlFile);
  GeneratedCommands.ensureExists();

  final invalidCommandKeys = yamlContent.keys.where((k) => !isValidCommandName(k)).toList();
  final validationErrorKeys = commandValidationErrors.keys.toList();

  // First, check which commands are reserved (before writing anything)
  final potentiallyAllowedCommands = Map.fromEntries(
    yamlContent.entries.where((e) => !invalidCommandKeys.contains(e.key) && !validationErrorKeys.contains(e.key)),
  );

  // Pass the commands being checked so they're excluded from generated executables check
  final commandsToCheck = potentiallyAllowedCommands.keys.toSet();
  final reservedCommandKeys = (await yamlContent.keys.mapNotNullAsync((k) async {
    if (invalidCommandKeys.contains(k) || validationErrorKeys.contains(k)) return null;
    final override = yamlContent[k]?.override ?? false;
    // Always check and cache reserved commands, but only block if override is false
    final isReserved = await ReservedCommands.isReserved(k, excludeFromGenerated: commandsToCheck);
    return !override && isReserved ? k : null;
  }))
      .toList();

  // Only write pubspec and bin files for truly allowed commands (excluding reserved)
  final allowedCommands = Map.fromEntries(
    yamlContent.entries.where((e) =>
        !invalidCommandKeys.contains(e.key) &&
        !validationErrorKeys.contains(e.key) &&
        !reservedCommandKeys.contains(e.key)),
  );

  final pubspecModified = writePubspec(GeneratedCommands.dir, allowedCommands.keys);
  final binFilesModified = writeBinFiles(GeneratedCommands.binDir, allowedCommands.keys);

  // Check current activation status and existing snapshots BEFORE any activation
  final isActivated = await isPackageActivated('generated_commands');
  final existingSnapshotsBefore = await getExistingSnapshots();
  final needsActivation = !isActivated || pubspecModified;

  // Activate if needed (this may wipe out .dart_tool directory)
  if (needsActivation || binFilesModified) {
    if (await activatePackage(GeneratedCommands.dir) != 0) {
      print('❌ Failed to activate commands');
      exit(1);
    }
  }

  // After activation, check which commands still need warmup
  // Use the snapshots list from BEFORE activation since activation wipes them
  final commandsNeedingWarmup = getCommandsNeedingWarmup(allowedCommands.keys, existingSnapshotsBefore);

  // Warm up new commands if needed
  if (commandsNeedingWarmup.isNotEmpty) {
    final s = commandsNeedingWarmup.length > 1 ? 's' : '';
    print('🔥 Warming up ${commandsNeedingWarmup.length} new command$s...');
    await warmUpCommands(commandsNeedingWarmup);

    // Reactivate after warmup to register snapshots
    await activatePackage(GeneratedCommands.dir);
  }

  final maxNameLength = yamlContent.keys.map((name) => name.length).reduce((a, b) => a > b ? a : b);

  allowedCommands.forEach((name, command) {
    final padding = ' ' * (maxNameLength - name.length + 1);

    print(
      '✅ $bold$green$name$reset:$padding$gray${command.description != null && command.description!.isNotEmpty ? (command.description!.endsWith('.') ? '${command.description} ' : '${command.description}. ') : ''}Type "$name --help" to learn more.$reset',
    );
  });

  for (final name in reservedCommandKeys) {
    final padding = ' ' * (maxNameLength - name.length + 1);

    print(
      '⚠️  $bold$yellow$name$reset:${padding}is a $bold${yellow}reserved$reset command. ${gray}In order to override it see: ${link('README', 'https://github.com/Nikoro/commands/blob/main/README.md#overriding-existing-commands')}$reset',
    );
  }

  for (final name in invalidCommandKeys) {
    final padding = ' ' * (maxNameLength - name.length + 1);

    print('❌ $bold$red$name$reset:${padding}contains invalid characters');
  }

  for (final name in validationErrorKeys) {
    final padding = ' ' * (maxNameLength - name.length + 1);
    final error = commandValidationErrors[name] ?? 'validation error';

    print('❌ $bold$red$name$reset:$padding$error');
  }

  await flushShellCache();
}
