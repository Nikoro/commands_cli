import 'dart:io';

import 'package:commands_cli/boolean_picker.dart';
import 'package:commands_cli/colors.dart';
import 'package:commands_cli/command.dart';
import 'package:commands_cli/command_validator.dart';
import 'package:commands_cli/commands_loader.dart';
import 'package:commands_cli/enum_picker.dart';
import 'package:commands_cli/param.dart';
import 'package:commands_cli/reserved_commands.dart';
import 'package:commands_cli/switch_picker.dart';
import 'package:commands_cli/yaml_file.dart';

Future<void> run(String name, List<String> args) async {
  // If no YAML file exists and command is reserved, execute the original
  if (!hasYamlFile) {
    if (await ReservedCommands.isReserved(name)) {
      final exitCode = await _executeOriginal(name, args);
      exit(exitCode);
    } else {
      stderr.writeln('❌ No commands.yaml found');
      exit(1);
    }
  }

  final commands = loadCommandsFrom(yamlFile);

  // Check if this command has validation errors (was invalid during loading)
  if (commandValidationErrors.containsKey(name)) {
    final error = commandValidationErrors[name]!;
    stderr.writeln(error.multiLineMessage);
    exit(1);
  }

  final command = commands[name];
  if (command == null) {
    if (await ReservedCommands.isReserved(name)) {
      final exitCode = await _executeOriginal(name, args);
      exit(exitCode);
    } else {
      stderr.writeln('❌ Command: $bold$red$name$reset not found in commands.yaml');
      exit(1);
    }
  }

  if (await ReservedCommands.isReserved(name) && !command.override) {
    final exitCode = await _executeOriginal(name, args);
    exit(exitCode);
  }

  const helpFlags = ['--help', '-h'];

  // Check for help BEFORE resolving switches so we can show the switch options
  final isHelpRequested = helpFlags.any(args.contains);

  // For commands with switches, check if help is requested before resolving
  if (isHelpRequested && command.hasSwitches) {
    final paramFlags = [
      ...command.requiredParams.map((p) => p.flags).whereType<String>(),
      ...command.optionalParams.map((p) => p.flags).whereType<String>(),
    ];
    final paramOverridesHelp = paramFlags.any((f) => helpFlags.any((hf) => f.contains(hf)));
    final isAlias = command.script?.contains('...args') ?? false;

    if (!paramOverridesHelp && !isAlias) {
      print('$blue$name$reset${command.description != null ? ': $gray${command.description}$reset' : ''}');
      _printSwitchesHelp(command, '');
      exit(0);
    }
  }

  // Resolve switches recursively before processing params
  final resolvedData = await _resolveSwitches(command, args, name);
  final resolvedCommand = resolvedData.command;
  final resolvedArgs = resolvedData.args;

  final paramFlags = [
    ...resolvedCommand.requiredParams.map((p) => p.flags).whereType<String>(),
    ...resolvedCommand.optionalParams.map((p) => p.flags).whereType<String>(),
  ];

  final paramOverridesHelp = paramFlags.any((f) => helpFlags.any((hf) => f.contains(hf)));
  final isAlias = resolvedCommand.script?.contains('...args') ?? false;

  // Handle help for non-switch commands or resolved switch commands with params
  if (helpFlags.any(resolvedArgs.contains) && !paramOverridesHelp && !isAlias) {
    print(
      '$blue$name$reset${resolvedCommand.description != null ? ': $gray${resolvedCommand.description}$reset' : ''}',
    );

    // Display params if command has them (don't show switches here, they were already handled above)
    if (resolvedCommand.requiredParams.isNotEmpty || resolvedCommand.optionalParams.isNotEmpty) {
      print('params:');
      if (resolvedCommand.requiredParams.isNotEmpty) {
        print('  required:');
        for (final param in resolvedCommand.requiredParams) {
          _printParamHelp(param);
        }
      }
      if (resolvedCommand.optionalParams.isNotEmpty) {
        print('  optional:');
        for (final param in resolvedCommand.optionalParams) {
          _printParamHelp(param);
        }
      }
    }
    exit(0);
  }

  var commandText = resolvedCommand.script ?? '';

  final commandValues = <String, String?>{};
  final positionalParams = <String>[];
  final optionalPositionalParams = <String>[];
  final optionalParamAliases = <String, String>{};

  for (final param in resolvedCommand.requiredParams) {
    if (param.flags != null) {
      final aliases = param.flags!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      for (final alias in aliases) {
        optionalParamAliases[alias] = param.name;
      }
    } else {
      positionalParams.add(param.name);
    }
    commandValues[param.name] = param.defaultValue;
  }

  for (final param in resolvedCommand.optionalParams) {
    if (param.flags != null) {
      final aliases = param.flags!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      for (final alias in aliases) {
        optionalParamAliases[alias] = param.name;
      }
    } else {
      optionalPositionalParams.add(param.name);
    }
    commandValues[param.name] = param.defaultValue;
  }

  final positionalArgs = <String>[];
  final passthroughArgs = <String>[];
  final argsCopy = List<String>.from(resolvedArgs);
  final missingValues = <String>[]; // Track params with missing values

  // Helper to get param object by name
  Param getParamByName(String name) {
    try {
      return resolvedCommand.requiredParams.firstWhere((p) => p.name == name);
    } catch (_) {
      try {
        return resolvedCommand.optionalParams.firstWhere((p) => p.name == name);
      } catch (_) {
        // Fallback - should not happen in normal flow
        return Param(name: name);
      }
    }
  }

  while (argsCopy.isNotEmpty) {
    final arg = argsCopy.removeAt(0);

    if (optionalParamAliases.containsKey(arg)) {
      final paramName = optionalParamAliases[arg]!;
      final param = getParamByName(paramName);
      final isRequired = resolvedCommand.requiredParams.any((p) => p.name == paramName);

      // Handle boolean flags - if boolean type, flag presence toggles default
      if (param.isBoolean) {
        // Check if there's an explicit value like --verbose=true
        if (argsCopy.isNotEmpty && !argsCopy.first.startsWith('-')) {
          final nextArg = argsCopy.first;
          if (nextArg == 'true' || nextArg == 'false') {
            commandValues[paramName] = argsCopy.removeAt(0);
          } else {
            // Invalid boolean value provided - detect actual type
            final valueType = EnumTypeValidator.getValueType(nextArg);
            stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[boolean]$reset');
            stderr.writeln('   Got: $nextArg $gray[$valueType]$reset');
            stderr.writeln('💡 Example: $bgGreen$black$name $arg true$reset or $bgGreen$black$name $arg false$reset');
            exit(1);
          }
        } else {
          // Flag present without value = toggle the default value
          final currentValue = commandValues[paramName] ?? 'false';
          commandValues[paramName] = currentValue == 'true' ? 'false' : 'true';
        }
      } else {
        // Non-boolean parameter - requires a value
        // Check if there's a value: either doesn't start with '-' OR is a negative number
        if (argsCopy.isNotEmpty && (!argsCopy.first.startsWith('-') || _isNegativeNumber(argsCopy.first))) {
          final value = argsCopy.removeAt(0);

          // Validate typed parameters first (before generic enum validation for better error messages)
          if (param.type == 'integer') {
            if (!EnumTypeValidator.isValidInt(value)) {
              final valueType = EnumTypeValidator.getValueType(value);
              stderr.writeln('❌ Parameter $bold$red$paramName$reset expects an $gray[integer]$reset');
              stderr.writeln('   Got: $value $gray[$valueType]$reset');
              stderr.writeln('💡 Example: $bgGreen$black$name $arg 3$reset');
              exit(1);
            }
            // For integer type, reject double values (must not have decimal point)
            final valueType = EnumTypeValidator.getValueType(value);
            if (valueType == 'double') {
              stderr.writeln('❌ Parameter $bold$red$paramName$reset expects an $gray[integer]$reset');
              stderr.writeln('   Got: $value $gray[double]$reset');
              stderr.writeln('💡 Example: $bgGreen$black$name $arg 3$reset');
              exit(1);
            }
          } else if (param.type == 'double') {
            if (!EnumTypeValidator.isValidDouble(value)) {
              final valueType = EnumTypeValidator.getValueType(value);
              stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[double]$reset');
              stderr.writeln('   Got: $value $gray[$valueType]$reset');
              stderr.writeln('💡 Example: $bgGreen$black$name $arg 3.14$reset');
              exit(1);
            }
            // For double type, reject integer values (must have decimal point)
            final valueType = EnumTypeValidator.getValueType(value);
            if (valueType == 'integer') {
              stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[double]$reset');
              stderr.writeln('   Got: $value $gray[integer]$reset');
              stderr.writeln('💡 Example: $bgGreen$black$name $arg 3.14$reset');
              exit(1);
            }
          } else if (param.type == 'number') {
            if (!EnumTypeValidator.isValidNumber(value)) {
              final valueType = EnumTypeValidator.getValueType(value);
              stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[number]$reset');
              stderr.writeln('   Got: $value $gray[$valueType]$reset');
              stderr.writeln('💡 Example: $bgGreen$black$name $arg 3$reset');
              exit(1);
            }
          }

          // Validate enum values (for enums without explicit type or when value matches type)
          if (param.isEnum && !param.isValidValue(value)) {
            stderr.writeln('❌ Parameter $bold$red$paramName$reset has invalid value: "$value"');
            final allowedValues = param.displayValues.map((v) => '$bold$green$v$reset').join(', ');
            stderr.writeln('💡 Must be one of: $allowedValues');
            exit(1);
          }

          commandValues[paramName] = value;
        } else {
          if (isRequired) {
            missingValues.add(paramName);
          }
        }
      }
    } else {
      positionalArgs.add(arg);
      passthroughArgs.add(arg);
    }
  }

  // Check if any required params are missing values
  if (missingValues.isNotEmpty) {
    stderr.writeln(
      '❌ Missing value for param${missingValues.length > 1 ? 's' : ''}: ${missingValues.map((p) => '$bold$red$p$reset').join(', ')}',
    );
    exit(1);
  }

  final missingPositional = <String>[];
  final missingNamed = <String>[];

  // Process positional parameters FIRST (before enum picker)
  // This ensures invalid values are caught and reported as errors
  // instead of triggering the interactive picker
  final allPositionalParams = positionalParams + optionalPositionalParams;
  for (var i = 0; i < allPositionalParams.length; i++) {
    final paramName = allPositionalParams[i];
    if (i < positionalArgs.length) {
      final value = positionalArgs[i];
      final param = getParamByName(paramName);

      // Validate typed parameters first (before generic enum validation for better error messages)
      // For boolean/integer/double typed enums, show type-specific error if type doesn't match
      if (param.type == 'boolean' && value != 'true' && value != 'false') {
        final valueType = EnumTypeValidator.getValueType(value);
        stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[boolean]$reset');
        stderr.writeln('   Got: $value $gray[$valueType]$reset');
        stderr.writeln('💡 Example: $bgGreen$black$name true$reset or $bgGreen$black$name false$reset');
        exit(1);
      }

      if (param.type == 'integer') {
        if (!EnumTypeValidator.isValidInt(value)) {
          final valueType = EnumTypeValidator.getValueType(value);
          stderr.writeln('❌ Parameter $bold$red$paramName$reset expects an $gray[integer]$reset');
          stderr.writeln('   Got: $value $gray[$valueType]$reset');
          stderr.writeln('💡 Example: $bgGreen$black$name 3$reset');
          exit(1);
        }
        // For integer type, reject double values (must not have decimal point)
        final valueType = EnumTypeValidator.getValueType(value);
        if (valueType == 'double') {
          stderr.writeln('❌ Parameter $bold$red$paramName$reset expects an $gray[integer]$reset');
          stderr.writeln('   Got: $value $gray[double]$reset');
          stderr.writeln('💡 Example: $bgGreen$black$name 3$reset');
          exit(1);
        }
      }

      if (param.type == 'double') {
        if (!EnumTypeValidator.isValidDouble(value)) {
          final valueType = EnumTypeValidator.getValueType(value);
          stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[double]$reset');
          stderr.writeln('   Got: $value $gray[$valueType]$reset');
          stderr.writeln('💡 Example: $bgGreen$black$name 3.14$reset');
          exit(1);
        }
        // For double type, reject integer values (must have decimal point)
        final valueType = EnumTypeValidator.getValueType(value);
        if (valueType == 'integer') {
          stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[double]$reset');
          stderr.writeln('   Got: $value $gray[integer]$reset');
          stderr.writeln('💡 Example: $bgGreen$black$name 3.14$reset');
          exit(1);
        }
      }

      if (param.type == 'number') {
        if (!EnumTypeValidator.isValidNumber(value)) {
          final valueType = EnumTypeValidator.getValueType(value);
          stderr.writeln('❌ Parameter $bold$red$paramName$reset expects a $gray[number]$reset');
          stderr.writeln('   Got: $value $gray[$valueType]$reset');
          stderr.writeln('💡 Example: $bgGreen$black$name 3$reset');
          exit(1);
        }
      }

      // Validate enum values (for enums without explicit type or when value matches type)
      if (param.isEnum && !param.isValidValue(value)) {
        stderr.writeln('❌ Parameter $bold$red$paramName$reset has invalid value: "$value"');
        final allowedValues = param.displayValues.map((v) => '$bold$green$v$reset').join(', ');
        stderr.writeln('💡 Must be one of: $allowedValues');
        exit(1);
      }

      commandValues[paramName] = value;
    } else if (commandValues[paramName] == null && positionalParams.contains(paramName)) {
      final param = getParamByName(paramName);
      // Only add non-picker params to missing positional list
      // Picker params will be handled by the picker section below
      if (!param.requiresEnumPicker && !param.requiresBooleanPicker) {
        missingPositional.add(paramName);
      }
    }
  }

  // Check if there are any missing non-picker required params
  // This determines whether we can show pickers or should report errors
  bool hasNonPickerMissingParams = false;
  for (final param in resolvedCommand.requiredParams) {
    if (param.flags != null &&
        commandValues[param.name] == null &&
        !param.requiresEnumPicker &&
        !param.requiresBooleanPicker) {
      hasNonPickerMissingParams = true;
      break;
    }
  }

  // Handle enum pickers for parameters without defaults and without provided values
  // Only show picker if ALL other required params (non-enum-picker) are already provided
  // AND there are no missing positional params
  // This runs AFTER positional processing to ensure invalid values are caught first
  if (!hasNonPickerMissingParams && missingPositional.isEmpty) {
    for (final param in resolvedCommand.requiredParams) {
      // Only show picker if:
      // 1. Parameter is an enum (has values)
      // 2. No default value exists
      // 3. No value has been provided yet
      // 4. Parameter is required (we're iterating requiredParams only)
      // 5. ALL other non-enum-picker required params are already provided
      // 6. No positional params are missing
      if (commandValues[param.name] == null) {
        String? selectedValue;

        // Use BooleanPicker for explicitly typed boolean parameters with values field
        if (param.requiresBooleanPicker) {
          selectedValue = BooleanPicker.pick(param.name, description: param.description);
        } else if (param.requiresEnumPicker) {
          selectedValue = EnumPicker.pick(param, param.name);
        }

        if (selectedValue != null) {
          commandValues[param.name] = selectedValue;
        } else if (param.requiresBooleanPicker || param.requiresEnumPicker) {
          // User cancelled - exit gracefully
          exit(0);
        }
      }
    }
  }

  // Collect all missing required params in declaration order
  for (final param in resolvedCommand.requiredParams) {
    if (param.flags != null) {
      if (commandValues[param.name] == null) {
        missingNamed.add(param.name);
      }
    }
  }

  if (missingPositional.isNotEmpty) {
    stderr.writeln(
      '❌ Missing required positional param${missingPositional.length > 1 ? 's' : ''}: ${missingPositional.map((p) => '$bold$red$p$reset').join(', ')}',
    );
    exit(1);
  }

  if (missingNamed.isNotEmpty) {
    stderr.writeln(
      '❌ Missing required named param${missingNamed.length > 1 ? 's' : ''}: ${missingNamed.map((p) => '$bold$red$p$reset').join(', ')}',
    );
    exit(1);
  }

  commandValues.forEach((k, v) {
    if (v != null) {
      commandText = commandText.replaceAll('{$k}', v);
    } else {
      commandText = commandText.replaceAll('{$k}', '');
    }
  });

  commandText = commandText.replaceAll('...args', passthroughArgs.join(' '));

  final process = await Process.start(
    Platform.isWindows ? 'cmd' : 'sh',
    Platform.isWindows ? ['/C', commandText] : ['-c', commandText],
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
}

/// Result of switch resolution containing the final command and remaining args
class _ResolvedSwitchData {
  const _ResolvedSwitchData(this.command, this.args);

  final Command command;
  final List<String> args;
}

/// Prints help text for switches with proper formatting
void _printSwitchesHelp(Command command, String indent) {
  if (!command.hasSwitches) return;

  print('${indent}options:');

  for (final switchName in command.switches.keys) {
    final switchCommand = command.switches[switchName]!;
    final switchInfo = command.getSwitchInfo(switchName);

    // Special formatting for switch named "default" - always bold
    final isSwitchNamedDefault = switchName == 'default';
    final nameFormatting = isSwitchNamedDefault ? bold : blue;

    // Build the switch line
    String flags = '';
    if (switchInfo?.flags != null && switchInfo!.flags!.isNotEmpty) {
      // Parse comma-separated flags and format each one with color
      final flagsList = switchInfo.flags!.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
      if (flagsList.isNotEmpty) {
        final formattedFlags = flagsList.map((flag) => '$nameFormatting$flag$reset').join(', ');
        flags = ' or $formattedFlags';
      }
    }
    // Don't show inline (default) marker anymore - we'll print default as a separate line
    final description = switchCommand.description != null ? ': $gray${switchCommand.description}$reset' : '';

    print('$indent  $nameFormatting$switchName$reset$flags$description');

    // If this switch has params, print them
    if (switchCommand.hasParameters) {
      print('$indent  params:');
      if (switchCommand.requiredParams.isNotEmpty) {
        print('$indent    required:');
        for (final param in switchCommand.requiredParams) {
          final paramFlags = param.flags != null ? ' (${param.flags})' : '';
          final description = param.description != null ? ' $gray${param.description}$reset' : '';
          print('$indent      $magenta${param.name}$paramFlags$reset$description');
          if (param.values != null && param.values!.isNotEmpty) {
            print('$indent      ${bold}values$reset: ${param.displayValues.join(', ')}');
          }
          if (param.defaultValue != null) {
            print('$indent      ${bold}default$reset: $bold$orange${param.defaultValue}$reset');
          }
        }
      }
      if (switchCommand.optionalParams.isNotEmpty) {
        print('$indent    optional:');
        for (final param in switchCommand.optionalParams) {
          final paramFlags = param.flags != null ? ' (${param.flags})' : '';
          final description = param.description != null ? ' $gray${param.description}$reset' : '';
          print('$indent      $magenta${param.name}$paramFlags$reset$description');
          if (param.values != null && param.values!.isNotEmpty) {
            print('$indent      ${bold}values$reset: ${param.displayValues.join(', ')}');
          }
          if (param.defaultValue != null) {
            print('$indent      ${bold}default$reset: $bold$orange${param.defaultValue}$reset');
          }
        }
      }
    }

    // Recursively print nested switches
    if (switchCommand.hasSwitches) {
      _printSwitchesHelp(switchCommand, '$indent  ');
    }
  }

  // Print the default marker at the end if there's a default and it's not named "default"
  if (command.defaultSwitch != null && command.defaultSwitch!.isNotEmpty && command.defaultSwitch != 'default') {
    print('$indent  ${bold}default$reset: $blue${command.defaultSwitch}$reset');
  }
}

/// Recursively resolves switches until a terminal command (with script) is found
Future<_ResolvedSwitchData> _resolveSwitches(Command command, List<String> args, String commandPath) async {
  // Base case: no switches, return as-is
  if (!command.hasSwitches) {
    return _ResolvedSwitchData(command, args);
  }

  // Try to match first arg to a switch
  String? selectedSwitch;
  List<String> remainingArgs = args;

  if (args.isNotEmpty) {
    final firstArg = args.first;
    final switchInfo = command.getSwitchInfo(firstArg);

    if (switchInfo != null) {
      selectedSwitch = switchInfo.name;
      remainingArgs = args.sublist(1); // Remove matched switch from args
    }
  }

  // If no match and no default, show picker
  if (selectedSwitch == null) {
    if (command.defaultSwitch != null) {
      selectedSwitch = command.defaultSwitch;
    } else {
      // Show picker - returns null if cancelled
      selectedSwitch = SwitchPicker.pick(command, commandPath);
      if (selectedSwitch == null) {
        stderr.writeln('$yellow No switch selected$reset');
        exit(0);
      }
    }
  }

  // Get the selected switch command
  final switchCommand = command.switches[selectedSwitch];
  if (switchCommand == null) {
    stderr.writeln('❌ Switch: $bold$red$selectedSwitch$reset not found');
    exit(1);
  }

  // Recursively resolve if the switch command also has switches
  final newCommandPath = '$commandPath $selectedSwitch';
  return _resolveSwitches(switchCommand, remainingArgs, newCommandPath);
}

Future<int> _executeOriginal(String name, List<String> args) async {
  final pubCacheBin = '${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/.pub-cache/bin';
  final command = File('$pubCacheBin/$name');
  final tempDir = Directory.systemTemp.createTempSync('commands_hide_');
  final tempCommand = File('${tempDir.path}/$name');

  if (command.existsSync()) {
    command.renameSync(tempCommand.path);
  }

  try {
    // Since we've temporarily moved the pub-cache executable, just run the command normally
    // The system will find the original command in PATH
    final process = await Process.start(
      name,
      args,
      mode: ProcessStartMode.inheritStdio,
    );

    return await process.exitCode;
  } finally {
    if (tempCommand.existsSync()) {
      tempCommand.renameSync(command.path);
      tempDir.deleteSync(recursive: true);
    }
  }
}

/// Checks if a string is a negative number (e.g., "-1", "-3.14", "-1.0")
/// This is used to distinguish between flags (like "-n") and negative numbers
bool _isNegativeNumber(String value) {
  if (!value.startsWith('-')) return false;
  // Try to parse as a number - if it succeeds, it's a negative number
  return double.tryParse(value) != null;
}

/// Prints help text for a single parameter with type information
void _printParamHelp(Param param) {
  final flags = param.flags != null ? ' (${param.flags})' : '';

  // Build the help line with proper formatting
  final buffer = StringBuffer('    $magenta${param.name}$flags$reset');

  // Show type if explicitly specified OR if type is inferred (non-null)
  if (param.type != null) {
    buffer.write(' $gray[${param.type}]');

    // If there's a description, add it within the same gray block (no reset between type and description)
    if (param.description != null) {
      buffer.write(' ${param.description}$reset');
    } else {
      buffer.write(reset);
    }
  } else if (param.description != null) {
    // No type info, just add description in gray
    buffer.write(' $gray${param.description}$reset');
  }

  print(buffer.toString());

  // Print values for enum types
  // For boolean types with values field, always show "true, false" regardless of actual values
  if (param.values != null) {
    if (param.type == 'boolean' || param.type == 'bool') {
      print('    ${bold}values$reset: true, false');
    } else if (param.values!.isNotEmpty) {
      print('    ${bold}values$reset: ${param.displayValues.join(', ')}');
    }
  }

  // Print default value
  if (param.defaultValue != null) {
    print('    ${bold}default$reset: $bold$orange${param.defaultValue}$reset');
  }
}
