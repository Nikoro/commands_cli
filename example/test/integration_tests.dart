import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart' show isTestGroup;
import 'package:test/test.dart';

final _commandsYaml = File('commands.yaml');
final _lock = _FileLock();

/// Simple lock to serialize file access across test groups
class _FileLock {
  var _current = Future<void>.value();

  Future<T> synchronized<T>(Future<T> Function() action) async {
    final previous = _current;
    final completer = Completer<void>();
    _current = completer.future;

    await previous;
    try {
      return await action();
    } finally {
      completer.complete();
    }
  }
}

@isTestGroup
void integrationTests(String description, dynamic Function() body) => group(description, () {
      late String originalContent;

      setUpAll(() async => await _lock.synchronized(() async {
            originalContent = await _commandsYaml.readAsString();
            await _commandsYaml.writeAsString(description);
          }));

      tearDownAll(() async => await _lock.synchronized(() async {
            await _commandsYaml.writeAsString(originalContent);
          }));

      body();
    });
