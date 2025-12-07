import 'package:commands_cli/param.dart';
import 'package:commands_cli/switch_info.dart';

class Command {
  const Command({
    this.script,
    this.description,
    this.requiredParams = const [],
    this.optionalParams = const [],
    this.override = false,
    this.switches = const {},
    this.defaultSwitch,
    this.flags,
  });

  /// The script to execute (renamed from commandText for consistency with YAML)
  /// Can be null if this command only has switches
  final String? script;

  /// Optional description for help text
  final String? description;

  /// Required parameters for this command
  final List<Param> requiredParams;

  /// Optional parameters for this command
  final List<Param> optionalParams;

  /// Whether this command overrides a reserved command
  final bool override;

  /// Map of switch name to Command (for hierarchical commands)
  /// Example: {"ios": Command(...), "android": Command(...)}
  final Map<String, Command> switches;

  /// Default switch to use when no switch is specified
  /// Can be either:
  /// - A switch name (String): "ios"
  /// - null: no default, show picker if switches exist
  final String? defaultSwitch;

  /// Optional flags/aliases for this command when used as a switch
  /// Example: "-s, --stg" for staging switch
  final String? flags;

  /// Computed list of SwitchInfo objects with metadata
  List<SwitchInfo> get switchesInfo {
    return switches.entries.map((entry) {
      return SwitchInfo(
        name: entry.key,
        command: entry.value,
        flags: entry.value.flags,
        description: entry.value.description,
      );
    }).toList();
  }

  /// Get SwitchInfo by matching name or flag alias
  SwitchInfo? getSwitchInfo(String arg) {
    return switchesInfo.cast<SwitchInfo?>().firstWhere((info) => info!.matches(arg), orElse: () => null);
  }

  /// Check if this command has switches
  bool get hasSwitches => switches.isNotEmpty;

  /// Check if this command has parameters
  bool get hasParameters => requiredParams.isNotEmpty || optionalParams.isNotEmpty;

  /// Check if this is a script command (has executable script)
  bool get isScriptCommand => script != null && script!.isNotEmpty;

  /// Backward compatibility: alias for script
  @Deprecated('Use script instead')
  String get commandText => script ?? '';

  String toStringRepresentation() {
    return 'Command(script: $script, switches: ${switches.keys}, default: $defaultSwitch)';
  }

  bool isEqual(Object other) =>
      identical(this, other) ||
      other is Command &&
          runtimeType == other.runtimeType &&
          script == other.script &&
          description == other.description &&
          requiredParams == other.requiredParams &&
          optionalParams == other.optionalParams &&
          override == other.override &&
          switches == other.switches &&
          defaultSwitch == other.defaultSwitch;

  int get hashValue =>
      Object.hash(script, description, requiredParams, optionalParams, override, switches, defaultSwitch);
}
