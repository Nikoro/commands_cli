import 'dart:io';

import 'package:meta/meta.dart' show isTestGroup;
import 'package:test/test.dart';

/// Typedef for the runCommand helper function passed to test bodies
typedef RunCommand = Future<ProcessResult> Function(String command, List<String> args);

/// Creates an isolated test environment with its own commands.yaml file.
///
/// Each test group gets a unique temp directory with its own commands.yaml,
/// allowing tests to run in parallel without conflicts.
@isTestGroup
void integrationTests(
  String description,
  dynamic Function(RunCommand runCommand) body,
) =>
    group(description, () {
      late Directory tempDir;

      setUpAll(() async {
        // Create unique temp directory for this test group
        tempDir = Directory.systemTemp.createTempSync('commands_test_');
        // Write test-specific YAML to this directory
        await File('${tempDir.path}/commands.yaml').writeAsString(description);
      });

      tearDownAll(() async {
        // Cleanup temp directory
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      // Helper runs commands from the temp directory (where its own commands.yaml lives)
      Future<ProcessResult> runCommand(String command, List<String> args) {
        return Process.run(command, args, workingDirectory: tempDir.path);
      }

      body(runCommand);
    });
