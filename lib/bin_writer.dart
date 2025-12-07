import 'dart:io';

void cleanOldBins(Directory binDir, Iterable yamlKeys) {
  final existingBins = binDir.existsSync() ? binDir.listSync().whereType<File>().toList() : [];
  final yamlSet = yamlKeys.toSet();
  for (final file in existingBins) {
    final name = file.uri.pathSegments.last.replaceAll('.dart', '');
    if (!yamlSet.contains(name)) {
      file.deleteSync();
    }
  }
}

/// Returns true if any bin files were modified
bool writeBinFiles(Directory binDir, Iterable keys) {
  bool modified = false;

  for (final name in keys) {
    final file = File('${binDir.path}/$name.dart');
    final content = '''
import 'package:commands_cli/run.dart';

Future<void> main(List<String> args) => run('$name', args);
''';

    if (!file.existsSync() || file.readAsStringSync() != content) {
      file.writeAsStringSync(content);
      modified = true;
    }
  }

  return modified;
}
