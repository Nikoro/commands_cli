import 'dart:io';

Future<void> flushShellCache() async {
  final shell = Platform.environment['SHELL'] ?? '';

  if (['bash', 'zsh', 'ksh'].any(shell.endsWith)) {
    await Process.run('hash', ['-r'], runInShell: true);
  } else if (['csh', 'tcsh'].any(shell.endsWith)) {
    await Process.run('rehash', [], runInShell: true);
  }
}
