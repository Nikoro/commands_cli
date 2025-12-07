import 'dart:io';

import 'package:commands_cli/bin_writer.dart';
import 'package:test/test.dart';

void main() {
  group('bin_writer', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('test_bin_writer_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('cleanOldBins', () {
      test('deletes bin files that are not in the yaml keys', () {
        // Arrange
        final fileToKeep = File('${tempDir.path}/keep.dart')..createSync();
        final fileToDelete = File('${tempDir.path}/delete.dart')..createSync();
        final yamlKeys = ['keep'];

        // Act
        cleanOldBins(tempDir, yamlKeys);

        // Assert
        expect(fileToKeep.existsSync(), isTrue);
        expect(fileToDelete.existsSync(), isFalse);
      });

      test('does not throw if bin directory does not exist', () {
        final nonExistentDir = Directory('${tempDir.path}/non_existent');
        expect(() => cleanOldBins(nonExistentDir, []), returnsNormally);
      });

      test('does not delete any files if all are in yaml keys', () {
        // Arrange
        final file1 = File('${tempDir.path}/a.dart')..createSync();
        final file2 = File('${tempDir.path}/b.dart')..createSync();
        final yamlKeys = ['a', 'b'];

        // Act
        cleanOldBins(tempDir, yamlKeys);

        // Assert
        expect(file1.existsSync(), isTrue);
        expect(file2.existsSync(), isTrue);
      });
    });

    group('writeBinFiles', () {
      test('creates a dart file for each key', () {
        // Arrange
        final keys = ['command1', 'command2'];

        // Act
        writeBinFiles(tempDir, keys);

        // Assert
        expect(File('${tempDir.path}/command1.dart').existsSync(), isTrue);
        expect(File('${tempDir.path}/command2.dart').existsSync(), isTrue);
      });

      test('writes correct content to the created files', () {
        // Arrange
        final keys = ['my_command'];
        final expectedContent = """
import 'package:commands_cli/run.dart';

Future<void> main(List<String> args) => run('my_command', args);
""";

        // Act
        writeBinFiles(tempDir, keys);

        // Assert
        final file = File('${tempDir.path}/my_command.dart');
        final content = file.readAsStringSync();
        expect(content, equals(expectedContent));
      });
    });
  });
}
