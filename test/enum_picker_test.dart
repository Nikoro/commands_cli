import 'package:test/test.dart';
import 'package:commands_cli/param.dart';

void main() {
  group('EnumPicker', () {
    test('param without values is not an enum', () {
      final param = Param(name: 'mode');

      expect(param.isEnum, false);
      expect(param.requiresEnumPicker, false);
    });

    test('param with values is an enum', () {
      final param = Param(
        name: 'env',
        values: ['dev', 'staging', 'prod'],
      );

      expect(param.isEnum, true);
      expect(param.values, ['dev', 'staging', 'prod']);
    });

    test('enum with default does not require picker', () {
      final param = Param(
        name: 'env',
        values: ['dev', 'staging', 'prod'],
        defaultValue: 'staging',
      );

      expect(param.isEnum, true);
      expect(param.requiresEnumPicker, false);
    });

    test('enum without default requires picker', () {
      final param = Param(
        name: 'target',
        values: ['ios', 'android', 'web'],
      );

      expect(param.isEnum, true);
      expect(param.requiresEnumPicker, true);
    });

    test('isValidValue validates enum values case-insensitively', () {
      final param = Param(
        name: 'env',
        values: ['dev', 'staging', 'prod'],
      );

      expect(param.isValidValue('dev'), true);
      expect(param.isValidValue('staging'), true);
      expect(param.isValidValue('prod'), true);
      expect(param.isValidValue('DEV'), true);
      expect(param.isValidValue('Staging'), true);
      expect(param.isValidValue('PROD'), true);
      expect(param.isValidValue('invalid'), false);
      expect(param.isValidValue('test'), false);
    });

    test('isValidValue returns true for non-enum params', () {
      final param = Param(name: 'port');

      expect(param.isValidValue('3000'), true);
      expect(param.isValidValue('anything'), true);
    });

    test('enum param with description', () {
      final param = Param(
        name: 'target',
        values: ['ios', 'android', 'web'],
        description: 'Select build target',
      );

      expect(param.isEnum, true);
      expect(param.description, 'Select build target');
    });

    test('enum param with flags', () {
      final param = Param(
        name: 'env',
        values: ['dev', 'staging', 'prod'],
        flags: '-e, --environment',
      );

      expect(param.isEnum, true);
      expect(param.flags, '-e, --environment');
    });

    test('enum param with empty values list is not an enum', () {
      final param = Param(
        name: 'mode',
        values: [],
      );

      expect(param.isEnum, false);
      expect(param.requiresEnumPicker, false);
    });

    test('mixed enum with all properties', () {
      final param = Param(
        name: 'mode',
        values: ['debug', 'release', 'profile'],
        defaultValue: 'debug',
        flags: '-m, --mode',
        description: 'Build mode',
        type: 'enum',
      );

      expect(param.isEnum, true);
      expect(param.requiresEnumPicker, false); // Has default
      expect(param.values, ['debug', 'release', 'profile']);
      expect(param.defaultValue, 'debug');
      expect(param.flags, '-m, --mode');
      expect(param.description, 'Build mode');
      expect(param.type, 'enum');
    });

    test('enum validation with single value', () {
      final param = Param(
        name: 'confirm',
        values: ['yes'],
      );

      expect(param.isEnum, true);
      expect(param.isValidValue('yes'), true);
      expect(param.isValidValue('YES'), true);
      expect(param.isValidValue('no'), false);
    });

    test('enum values are case-preserved', () {
      final param = Param(
        name: 'format',
        values: ['JSON', 'XML', 'YAML'],
      );

      expect(param.values, ['JSON', 'XML', 'YAML']);
      expect(param.isValidValue('json'), true); // Case-insensitive validation
      expect(param.isValidValue('JSON'), true);
    });
  });
}
