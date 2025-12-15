import 'dart:convert';
import 'dart:io';

import 'package:commands_cli/installation_source.dart';

class VersionCheckResult {
  final String currentVersion;
  final String? latestVersion;
  final String? changelogUrl;

  VersionCheckResult({
    required this.currentVersion,
    this.latestVersion,
    this.changelogUrl,
  });

  bool get hasNewerVersion {
    if (latestVersion == null) return false;
    return _compareVersions(currentVersion, latestVersion!) < 0;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return parts1.length.compareTo(parts2.length);
  }
}

/// Checks for available updates of commands_cli
Future<VersionCheckResult?> checkForUpdate(String currentVersion) async {
  final installationInfo = await detectInstallationSource();

  if (installationInfo.source == InstallationSource.git) {
    return await _checkGitHubRelease(currentVersion, installationInfo.gitUrl);
  } else {
    return await _checkPubDev(currentVersion);
  }
}

/// Check latest version from pub.dev
Future<VersionCheckResult?> _checkPubDev(String currentVersion) async {
  try {
    final result = await Process.run(
      'dart',
      ['pub', 'search', 'commands_cli', '--format', 'json'],
      runInShell: true,
    );

    if (result.exitCode != 0) return null;

    final jsonOutput = jsonDecode(result.stdout.toString());
    final packages = jsonOutput['packages'] as List?;

    if (packages == null || packages.isEmpty) return null;

    final commandsCliPackage = packages.firstWhere(
      (pkg) => pkg['package'] == 'commands_cli',
      orElse: () => null,
    );

    if (commandsCliPackage == null) return null;

    final latestVersion = commandsCliPackage['version'] as String?;

    return VersionCheckResult(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      changelogUrl: 'https://pub.dev/packages/commands_cli/changelog',
    );
  } catch (e) {
    return null;
  }
}

/// Check latest version from GitHub releases
Future<VersionCheckResult?> _checkGitHubRelease(String currentVersion, String? gitUrl) async {
  if (gitUrl == null) return null;

  try {
    // Extract owner/repo from git URL
    final match = RegExp(r'github\.com[:/]([^/]+)/([^/.]+)').firstMatch(gitUrl);
    if (match == null) return null;

    final owner = match.group(1);
    final repo = match.group(2);

    // Fetch latest release from GitHub API
    final result = await Process.run(
      'curl',
      [
        '-s',
        '-H',
        'Accept: application/vnd.github.v3+json',
        'https://api.github.com/repos/$owner/$repo/releases/latest',
      ],
      runInShell: true,
    );

    if (result.exitCode != 0) return null;

    final jsonOutput = jsonDecode(result.stdout.toString());
    final tagName = jsonOutput['tag_name'] as String?;

    if (tagName == null) return null;

    // Remove 'v' prefix if present
    final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    return VersionCheckResult(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      changelogUrl: 'https://github.com/$owner/$repo/releases/tag/$tagName',
    );
  } catch (e) {
    return null;
  }
}
