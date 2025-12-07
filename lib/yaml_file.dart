import 'dart:io';

File? _yamlFileCache;

File get yamlFile {
  if (_yamlFileCache != null) return _yamlFileCache!;

  final file = ['commands.yaml', 'commands.yml'].map((f) => File(f)).firstWhere(
        (f) => f.existsSync(),
        orElse: () => File(''),
      );

  _yamlFileCache = file;
  return file;
}

bool get hasYamlFile => yamlFile.path.isNotEmpty && yamlFile.existsSync();
