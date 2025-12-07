import 'dart:io';

import 'package:commands_cli/colors.dart';

Future<void> handleUpdate() async {
  final isGlobalExecution = Platform.script.toFilePath().contains('.pub-cache/global_packages');

  final ProcessResult result;

  if (isGlobalExecution) {
    // Determine if installed from git or pub.dev
    final installationSource = await _detectInstallationSource();

    if (installationSource == InstallationSource.git) {
      // Update from git repository
      final gitUrl = await _getGitUrl();
      print('${bold}Updating global commands_cli package from git...$reset\n');
      result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', '--source', 'git', gitUrl],
        runInShell: true,
      );
    } else {
      // Update from pub.dev
      print('${bold}Updating global commands_cli package...$reset\n');
      result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'commands_cli'],
        runInShell: true,
      );
    }
  } else {
    // Update local dependency
    print('${bold}Updating local commands_cli dependency...$reset\n');
    result = await Process.run(
      'dart',
      ['pub', 'upgrade', 'commands_cli'],
      runInShell: true,
    );
  }

  if (result.exitCode == 0) {
    final output = result.stdout.toString();
    print(output);

    // Check if already up to date
    if (output.contains('is already active') || output.contains('already using')) {
      print('$bold$blue Already up to date!$reset');
    } else {
      print('$bold$green✓ Successfully updated!$reset');
    }
  } else {
    print('$red✗ Update failed:$reset');
    print(result.stderr);
    exit(1);
  }
}

enum InstallationSource {
  git,
  hosted,
}

Future<InstallationSource> _detectInstallationSource() async {
  try {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return InstallationSource.hosted;

    final pubspecLockPath = '$home/.pub-cache/global_packages/commands_cli/pubspec.lock';
    final pubspecLockFile = File(pubspecLockPath);

    if (!await pubspecLockFile.exists()) {
      return InstallationSource.hosted;
    }

    final content = await pubspecLockFile.readAsString();

    // Check if it's a git source
    if (content.contains('source: git')) {
      return InstallationSource.git;
    }

    return InstallationSource.hosted;
  } catch (e) {
    // If we can't detect, assume hosted (pub.dev)
    return InstallationSource.hosted;
  }
}

Future<String> _getGitUrl() async {
  try {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return 'https://github.com/Nikoro/commands_cli.git';

    final pubspecLockPath = '$home/.pub-cache/global_packages/commands_cli/pubspec.lock';
    final pubspecLockFile = File(pubspecLockPath);

    if (!await pubspecLockFile.exists()) {
      return 'https://github.com/Nikoro/commands_cli.git';
    }

    final content = await pubspecLockFile.readAsString();

    // Extract the git URL from pubspec.lock
    final urlMatch = RegExp(r'url:\s*"?([^"\s]+)"?').firstMatch(content);
    if (urlMatch != null) {
      return urlMatch.group(1)!;
    }

    // Fallback to default repository
    return 'https://github.com/Nikoro/commands_cli.git';
  } catch (e) {
    // Fallback to default repository
    return 'https://github.com/Nikoro/commands_cli.git';
  }
}
