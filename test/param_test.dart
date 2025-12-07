import 'package:commands_cli/param.dart';
import 'package:test/test.dart';

void main() {
  group('Param', () {
    test('creates an instance with all properties', () {
      const param = Param(
        name: 'testName',
        flags: '--test, -t',
        description: 'A test parameter.',
        defaultValue: 'default',
      );

      expect(param.name, 'testName');
      expect(param.flags, '--test, -t');
      expect(param.description, 'A test parameter.');
      expect(param.defaultValue, 'default');
    });

    test('creates an instance with only the required name property', () {
      const param = Param(name: 'testName');

      expect(param.name, 'testName');
      expect(param.flags, isNull);
      expect(param.description, isNull);
      expect(param.defaultValue, isNull);
    });

    test('creates an instance with name and flags', () {
      const param = Param(name: 'testName', flags: '--test, -t');

      expect(param.name, 'testName');
      expect(param.flags, '--test, -t');
      expect(param.description, isNull);
      expect(param.defaultValue, isNull);
    });

    test('creates an instance with name and description', () {
      const param = Param(name: 'testName', description: 'A test description.');

      expect(param.name, 'testName');
      expect(param.flags, isNull);
      expect(param.description, 'A test description.');
      expect(param.defaultValue, isNull);
    });

    test('creates an instance with name and defaultValue', () {
      const param = Param(name: 'testName', defaultValue: 'default');

      expect(param.name, 'testName');
      expect(param.flags, isNull);
      expect(param.description, isNull);
      expect(param.defaultValue, 'default');
    });

    test('instances with the same properties are equal because of const constructor', () {
      const param1 = Param(
        name: 'testName',
        flags: '--test, -t',
        description: 'A test parameter.',
        defaultValue: 'default',
      );
      const param2 = Param(
        name: 'testName',
        flags: '--test, -t',
        description: 'A test parameter.',
        defaultValue: 'default',
      );

      expect(identical(param1, param2), isTrue);
    });

    test('instances with different properties are not equal', () {
      const param1 = Param(name: 'testName');
      const param2 = Param(name: 'anotherName');

      expect(param1, isNot(equals(param2)));
    });
  });

  group('Param - Type System', () {
    group('Boolean Parameters', () {
      test('isBoolean is true when type is explicitly boolean', () {
        const param = Param(name: 'verbose', type: 'boolean');
        expect(param.isBoolean, isTrue);
      });

      test('isBoolean is false when default is "true" without explicit type', () {
        const param = Param(name: 'verbose', defaultValue: 'true');
        expect(param.isBoolean, isFalse);
      });

      test('isBoolean is false when default is "false" without explicit type', () {
        const param = Param(name: 'verbose', defaultValue: 'false');
        expect(param.isBoolean, isFalse);
      });

      test('isBoolean is true when type is boolean even with string-like default', () {
        const param = Param(name: 'verbose', type: 'boolean', defaultValue: 'true');
        expect(param.isBoolean, isTrue);
      });

      test('isBoolean is false for non-boolean parameters', () {
        const param = Param(name: 'name', defaultValue: 'value');
        expect(param.isBoolean, isFalse);
      });

      test('booleanDefault returns true when default is "true"', () {
        const param = Param(name: 'verbose', defaultValue: 'true');
        expect(param.booleanDefault, isTrue);
      });

      test('booleanDefault returns false when default is "false"', () {
        const param = Param(name: 'verbose', defaultValue: 'false');
        expect(param.booleanDefault, isFalse);
      });

      test('booleanDefault returns false when no default', () {
        const param = Param(name: 'verbose', type: 'boolean');
        expect(param.booleanDefault, isFalse);
      });
    });

    group('Enum Parameters', () {
      test('isEnum is true when values list is provided', () {
        const param = Param(name: 'env', values: ['dev', 'staging', 'prod']);
        expect(param.isEnum, isTrue);
      });

      test('isEnum is false when values list is empty', () {
        const param = Param(name: 'env', values: []);
        expect(param.isEnum, isFalse);
      });

      test('isEnum is false when values is null', () {
        const param = Param(name: 'env');
        expect(param.isEnum, isFalse);
      });

      test('isValidValue returns true for valid enum value', () {
        const param = Param(name: 'env', values: ['dev', 'staging', 'prod']);
        expect(param.isValidValue('dev'), isTrue);
        expect(param.isValidValue('staging'), isTrue);
        expect(param.isValidValue('prod'), isTrue);
      });

      test('isValidValue returns true for case-insensitive match', () {
        const param = Param(name: 'env', values: ['dev', 'staging', 'prod']);
        expect(param.isValidValue('DEV'), isTrue);
        expect(param.isValidValue('Staging'), isTrue);
        expect(param.isValidValue('PROD'), isTrue);
      });

      test('isValidValue returns false for invalid enum value', () {
        const param = Param(name: 'env', values: ['dev', 'staging', 'prod']);
        expect(param.isValidValue('invalid'), isFalse);
        expect(param.isValidValue('test'), isFalse);
      });

      test('isValidValue returns true for non-enum parameters', () {
        const param = Param(name: 'name');
        expect(param.isValidValue('anything'), isTrue);
      });

      test('requiresEnumPicker is true for enum without default', () {
        const param = Param(name: 'env', values: ['dev', 'staging', 'prod']);
        expect(param.requiresEnumPicker, isTrue);
      });

      test('requiresEnumPicker is false for enum with default', () {
        const param = Param(
          name: 'env',
          values: ['dev', 'staging', 'prod'],
          defaultValue: 'staging',
        );
        expect(param.requiresEnumPicker, isFalse);
      });

      test('requiresEnumPicker is false for non-enum', () {
        const param = Param(name: 'name', defaultValue: 'value');
        expect(param.requiresEnumPicker, isFalse);
      });
    });

    group('Numeric Types', () {
      test('parseValue returns int for int type', () {
        const param = Param(name: 'port', type: 'int');
        expect(param.parseValue('8080'), equals(8080));
        expect(param.parseValue('0'), equals(0));
        expect(param.parseValue('-42'), equals(-42));
      });

      test('parseValue throws for invalid int', () {
        const param = Param(name: 'port', type: 'int');
        expect(() => param.parseValue('abc'), throwsFormatException);
        expect(() => param.parseValue('3.14'), throwsFormatException);
      });

      test('parseValue returns double for double type', () {
        const param = Param(name: 'timeout', type: 'double');
        expect(param.parseValue('3.14'), equals(3.14));
        expect(param.parseValue('42'), equals(42.0));
        expect(param.parseValue('1e5'), equals(100000.0));
      });

      test('parseValue throws for invalid double', () {
        const param = Param(name: 'timeout', type: 'double');
        expect(() => param.parseValue('abc'), throwsFormatException);
      });
    });

    group('parseValue', () {
      test('returns bool for boolean type', () {
        const param = Param(name: 'verbose', type: 'boolean');
        expect(param.parseValue('true'), equals(true));
        expect(param.parseValue('false'), equals(false));
        expect(param.parseValue('TRUE'), equals(true));
        expect(param.parseValue('FALSE'), equals(false));
      });

      test('throws for invalid boolean value', () {
        const param = Param(name: 'verbose', type: 'boolean');
        expect(() => param.parseValue('yes'), throwsFormatException);
        expect(() => param.parseValue('1'), throwsFormatException);
      });

      test('returns string for string type', () {
        const param = Param(name: 'name', type: 'string');
        expect(param.parseValue('test'), equals('test'));
        expect(param.parseValue('123'), equals('123'));
      });

      test('returns string when no type specified', () {
        const param = Param(name: 'name');
        expect(param.parseValue('test'), equals('test'));
        expect(param.parseValue('123'), equals('123'));
      });
    });

    group('Type with Enum Combination', () {
      test('can have both type and values', () {
        const param = Param(
          name: 'priority',
          type: 'int',
          values: ['1', '2', '3'],
        );
        expect(param.isEnum, isTrue);
        expect(param.type, equals('int'));
      });
    });

    group('Type Inference from Default Values', () {
      test('unquoted boolean-like defaults require explicit type to be boolean', () {
        // Without explicit type, even "true"/"false" defaults don't make it boolean
        const param = Param(
          name: 'verbose',
          defaultValue: 'true',
        );
        expect(param.isBoolean, isFalse);
        expect(param.booleanDefault, isTrue); // Can still read as boolean
      });

      test('explicit boolean type makes parameter boolean', () {
        const param = Param(
          name: 'debug',
          type: 'boolean',
          defaultValue: 'false',
        );
        expect(param.isBoolean, isTrue);
        expect(param.booleanDefault, isFalse);
      });

      test('explicit boolean type overrides inference', () {
        const param = Param(
          name: 'enabled',
          type: 'boolean',
          defaultValue: 'true',
        );
        expect(param.isBoolean, isTrue);
        expect(param.type, equals('boolean'));
      });

      test('explicit int type', () {
        const param = Param(
          name: 'port',
          type: 'int',
          defaultValue: '8080',
        );
        expect(param.type, equals('int'));
        expect(param.parseValue('3000'), equals(3000));
      });

      test('explicit double type', () {
        const param = Param(
          name: 'ratio',
          type: 'double',
          defaultValue: '1.5',
        );
        expect(param.type, equals('double'));
        expect(param.parseValue('2.5'), equals(2.5));
      });

      test('explicit string type', () {
        const param = Param(
          name: 'name',
          type: 'string',
          defaultValue: 'test',
        );
        expect(param.type, equals('string'));
        expect(param.parseValue('hello'), equals('hello'));
      });

      test('int parses correctly', () {
        const param = Param(name: 'count', type: 'int');
        expect(param.parseValue('42'), equals(42));
        expect(param.parseValue('0'), equals(0));
        expect(param.parseValue('-10'), equals(-10));
      });

      test('double parses correctly', () {
        const param = Param(name: 'ratio', type: 'double');
        expect(param.parseValue('3.14'), equals(3.14));
        expect(param.parseValue('0.5'), equals(0.5));
        expect(param.parseValue('-1.5'), equals(-1.5));
        expect(param.parseValue('42'), equals(42.0));
      });

      test('string handles numeric-looking values', () {
        const param = Param(name: 'code', type: 'string');
        expect(param.parseValue('123'), equals('123'));
        expect(param.parseValue('3.14'), equals('3.14'));
      });

      test('no type defaults to string', () {
        const param = Param(name: 'value');
        expect(param.parseValue('anything'), equals('anything'));
        expect(param.parseValue('123'), equals('123'));
        expect(param.parseValue('true'), equals('true'));
      });
    });

    group('Quoted Default Values', () {
      test('quoted int string is still treated as int type', () {
        // After quotes are stripped in YAML parsing, "8080" becomes 8080
        const param = Param(name: 'port', type: 'int', defaultValue: '8080');
        expect(param.type, equals('int'));
        expect(param.parseValue('3000'), equals(3000));
      });

      test('quoted double string is still treated as double type', () {
        // After quotes are stripped, "0.5" becomes 0.5
        const param = Param(name: 'ratio', type: 'double', defaultValue: '0.5');
        expect(param.type, equals('double'));
        expect(param.parseValue('0.75'), equals(0.75));
      });

      test('quoted boolean string becomes string type, not boolean', () {
        // After quotes are stripped, "true" is just a string without explicit type
        const param = Param(name: 'enabled', defaultValue: 'true');
        expect(param.isBoolean, isFalse);
        expect(param.booleanDefault, isTrue); // Can still be read as boolean value
      });

      test('quoted numeric-looking string can be explicit string type', () {
        // If explicitly typed as string, numeric-looking values stay as strings
        const param = Param(name: 'code', type: 'string', defaultValue: '123');
        expect(param.type, equals('string'));
        expect(param.parseValue('456'), equals('456'));
      });
    });
  });
}
