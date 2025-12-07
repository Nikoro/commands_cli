import 'package:commands_cli/command.dart';
import 'package:commands_cli/param.dart';
import 'package:test/test.dart';

void main() {
  group('Command', () {
    test('instantiates with only required script', () {
      const command = Command(script: 'test');
      expect(command.script, 'test');
      expect(command.description, isNull);
      expect(command.requiredParams, isEmpty);
      expect(command.optionalParams, isEmpty);
      expect(command.override, isFalse);
    });

    test('instantiates with all parameters', () {
      const requiredParam = Param(name: 'req');
      const optionalParam = Param(name: 'opt');
      const command = Command(
        script: 'test',
        description: 'A test command',
        requiredParams: [requiredParam],
        optionalParams: [optionalParam],
        override: true,
      );

      expect(command.script, 'test');
      expect(command.description, 'A test command');
      expect(command.requiredParams, [requiredParam]);
      expect(command.optionalParams, [optionalParam]);
      expect(command.override, isTrue);
    });

    test('override defaults to false', () {
      const command = Command(script: 'test');
      expect(command.override, isFalse);
    });

    test('correctly assigns required and optional params', () {
      const requiredParam1 = Param(name: 'req1');
      const requiredParam2 = Param(name: 'req2');
      const optionalParam1 = Param(name: 'opt1');
      const optionalParam2 = Param(name: 'opt2');
      const command = Command(
        script: 'test',
        requiredParams: [requiredParam1, requiredParam2],
        optionalParams: [optionalParam1, optionalParam2],
      );

      expect(command.requiredParams, hasLength(2));
      expect(command.requiredParams, containsAll([requiredParam1, requiredParam2]));
      expect(command.optionalParams, hasLength(2));
      expect(command.optionalParams, containsAll([optionalParam1, optionalParam2]));
    });

    test('instantiates with empty params', () {
      const command = Command(script: 'test', requiredParams: [], optionalParams: []);

      expect(command.requiredParams, isEmpty);
      expect(command.optionalParams, isEmpty);
    });

    test('instantiates with description but no params', () {
      const command = Command(script: 'test', description: 'A test command');
      expect(command.script, 'test');
      expect(command.description, 'A test command');
      expect(command.requiredParams, isEmpty);
      expect(command.optionalParams, isEmpty);
      expect(command.override, isFalse);
    });

    test('instantiates with params but no description', () {
      const requiredParam = Param(name: 'req');
      const optionalParam = Param(name: 'opt');
      const command = Command(script: 'test', requiredParams: [requiredParam], optionalParams: [optionalParam]);
      expect(command.script, 'test');
      expect(command.description, isNull);
      expect(command.requiredParams, [requiredParam]);
      expect(command.optionalParams, [optionalParam]);
      expect(command.override, isFalse);
    });

    test('instantiates with override set to true', () {
      const command = Command(script: 'test', override: true);
      expect(command.script, 'test');
      expect(command.description, isNull);
      expect(command.requiredParams, isEmpty);
      expect(command.optionalParams, isEmpty);
      expect(command.override, isTrue);
    });
  });
}
