import 'dart:io';
import 'package:test/test.dart';
import 'package:commands_cli/pubspec_writer.dart';

void main() {
  group('writePubspec', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('test_pubspec_writer');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('creates pubspec.yaml with correct content', () {
      final keys = ['command1', 'command2'];

      writePubspec(tempDir, keys);

      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final expectedContent = '''
name: generated_commands
description: Generated commands from commands.yaml
version: 1.0.0
environment:
  sdk: ^3.0.0

dev_dependencies:
  commands_cli:
    git:
      url: https://github.com/Nikoro/commands_cli.git

executables:
  command1: command1
  command2: command2
''';
      expect(pubspecFile.readAsStringSync(), expectedContent);
    });

    test('creates pubspec.yaml with no executables when keys are empty', () {
      final keys = <String>[];

      writePubspec(tempDir, keys);

      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final expectedContent = '''
name: generated_commands
description: Generated commands from commands.yaml
version: 1.0.0
environment:
  sdk: ^3.0.0

dev_dependencies:
  commands_cli:
    git:
      url: https://github.com/Nikoro/commands_cli.git

executables:

''';
      expect(pubspecFile.readAsStringSync(), expectedContent);
    });
  });
}
