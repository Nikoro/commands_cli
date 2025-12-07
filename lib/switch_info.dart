import 'package:commands_cli/command.dart';

/// Metadata for a single switch option within a command.
///
/// Example YAML:
/// ```yaml
/// deploy:
///   switch:
///     staging: "-s, --stg" ## Deploy to staging
///       script: echo "Deploying to staging"
/// ```
///
/// This creates a SwitchInfo with:
/// - name: "staging"
/// - flags: "-s, --stg"
/// - description: "Deploy to staging"
/// - command: Command with the script
class SwitchInfo {
  const SwitchInfo({required this.name, required this.command, this.flags, this.description});

  /// The switch name (e.g., "staging", "ios", "unit")
  final String name;

  /// The command to execute when this switch is selected
  final Command command;

  /// Optional flags/aliases (e.g., "-s, --stg")
  final String? flags;

  /// Optional description for help text and picker menu
  final String? description;

  /// All aliases for this switch (name + parsed flags)
  /// For "staging" with flags "-s, --stg", returns: ["staging", "-s", "--stg"]
  List<String> get aliases {
    final result = [name];
    if (flags != null && flags!.isNotEmpty) {
      // Parse comma-separated flags: "-s, --stg" -> ["-s", "--stg"]
      result.addAll(flags!.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty));
    }
    return result;
  }

  /// Check if this switch matches the given argument
  /// Matches by name or any flag alias
  bool matches(String arg) => aliases.contains(arg);

  @override
  String toString() => 'SwitchInfo($name, flags: $flags, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          flags == other.flags &&
          description == other.description &&
          command == other.command;

  @override
  int get hashCode => Object.hash(name, flags, description, command);
}
