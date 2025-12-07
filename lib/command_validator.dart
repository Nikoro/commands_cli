import 'package:commands_cli/colors.dart';

final _allowedCommandPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

bool isValidCommandName(String name) => _allowedCommandPattern.hasMatch(name);

/// Validator for command definitions to ensure correct structure and relationships
class CommandValidator {
  /// Validates that a command doesn't mix incompatible properties
  ///
  /// Critical rules:
  /// 1. Cannot have both 'script' AND 'switch' at the same level
  /// 2. Cannot have both 'params' AND 'switch' at the same level
  /// 3. If 'default' is a string reference, it must point to an existing switch
  /// 4. Switch names must be valid identifiers
  static ValidationResult validate(String commandName, Map<String, dynamic> commandData) {
    final hasScript = commandData.containsKey('script');
    final hasSwitch = commandData.containsKey('switch');
    final hasParams = commandData.containsKey('params');

    // Rule 1: Script + Switch conflict
    if (hasScript && hasSwitch) {
      return ValidationResult.error(
        'Cannot use both $bold${red}script$reset and $bold${red}switch$reset at the same time',
        hint: 'Move your script content into a \'default\' switch case',
      );
    }

    // Rule 2: Params + Switch conflict
    if (hasParams && hasSwitch) {
      return ValidationResult.error(
        'Cannot use \'params\' and \'switch\' at the same level in command: $commandName',
        hint: 'Parameters should be defined within individual switch cases, not at the switch level',
      );
    }

    // Rule 3: Validate default reference if it exists
    if (hasSwitch && commandData['switch'] is Map) {
      final switches = commandData['switch'] as Map<String, dynamic>;
      final defaultValue = switches['default'];

      if (defaultValue is String) {
        // Default references another switch by name
        if (!switches.containsKey(defaultValue)) {
          return ValidationResult.error(
            'Default switch \'$defaultValue\' does not exist in command: $commandName',
            hint: 'Available switches: ${switches.keys.where((k) => k != 'default').join(', ')}',
          );
        }

        // Check for self-reference
        if (defaultValue == 'default') {
          return ValidationResult.error(
            'Default switch cannot reference itself in command: $commandName',
            hint: 'Point default to an existing switch name or define default as a command',
          );
        }
      }

      // Rule 4: Validate switch names
      for (final switchName in switches.keys) {
        if (switchName == 'default') continue; // 'default' is allowed reserved word

        if (!_isValidSwitchName(switchName)) {
          return ValidationResult.error(
            'Invalid switch name \'$switchName\' in command: $commandName',
            hint: 'Switch names must be valid identifiers (letters, numbers, hyphens, underscores)',
          );
        }
      }

      // Recursively validate nested switches
      for (final entry in switches.entries) {
        if (entry.key == 'default' && entry.value is String) continue;

        final switchData = entry.value;
        if (switchData is Map<String, dynamic>) {
          final nestedResult = validate('$commandName > ${entry.key}', switchData);
          if (!nestedResult.isValid) {
            return nestedResult;
          }
        }
      }
    }

    return ValidationResult.success();
  }

  /// Check if a switch name follows valid naming conventions
  static bool _isValidSwitchName(String name) {
    // Allow letters, numbers, hyphens, and underscores
    final pattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    return pattern.hasMatch(name);
  }

  /// Validate switch flags format
  static bool isValidFlagsFormat(String flags) {
    // Flags should be comma-separated, starting with - or --
    // Examples: "-s", "--stg", "-s, --stg", "-p, --prod"
    final parts = flags.split(',').map((f) => f.trim());
    return parts.every((part) => part.startsWith('-') || part.startsWith('--'));
  }

  /// Validates parameter type and default value compatibility
  ///
  /// Rules:
  /// 1. Quoted default values are strings, so they cannot be used with explicit non-string types
  /// 2. Explicit string type should not have numeric unquoted defaults
  static ValidationResult validateParamTypeCompatibility(
    String? paramName,
    String? type,
    String? defaultValue,
    bool wasQuoted,
  ) {
    if (defaultValue == null || type == null) {
      return ValidationResult.success();
    }

    // Rule 1: If default value was quoted and type is explicitly non-string, that's an error
    if (wasQuoted && type != 'string') {
      return ValidationResult.error(
        'Parameter $bold$red$paramName$reset is declared as type $gray[$type]$reset, but its default value is $gray[string]$reset',
        hint:
            'Quoted values are always strings. Either remove quotes (default: $defaultValue) or change type to string',
      );
    }

    // Rule 2: If type is explicitly string but default is numeric (unquoted), that's an error
    if (!wasQuoted && type == 'string') {
      final isInt = int.tryParse(defaultValue) != null && !defaultValue.contains('.');
      final isDouble = double.tryParse(defaultValue) != null && defaultValue.contains('.');

      if (isInt || isDouble) {
        final actualType = isInt ? 'int' : 'double';
        return ValidationResult.error(
          'Parameter $bold$red$paramName$reset is declared as type $gray[string]$reset, but its default value is $gray[$actualType]$reset',
          hint:
              'Add quotes around numeric values for string type (default: "$defaultValue") or change type to $actualType',
        );
      }
    }

    return ValidationResult.success();
  }
}

/// Result of a validation operation
class ValidationResult {
  const ValidationResult({required this.isValid, this.errorMessage, this.hint});

  factory ValidationResult.success() => const ValidationResult(isValid: true);

  factory ValidationResult.error(String message, {String? hint}) {
    return ValidationResult(isValid: false, errorMessage: message, hint: hint);
  }

  final bool isValid;
  final String? errorMessage;
  final String? hint;

  String get fullMessage {
    final buffer = StringBuffer();
    if (errorMessage != null) {
      buffer.writeln('❌ $errorMessage');
    }
    if (hint != null) {
      buffer.writeln('💡 Hint: $hint');
    }
    return buffer.toString().trimRight();
  }
}
