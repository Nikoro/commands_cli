import 'package:test/test.dart';
import 'package:commands_cli/command.dart';

void main() {
  group('SwitchPicker', () {
    test('returns null for command without switches', () {
      final command = Command(script: 'echo "hello"');

      // Command without switches should have empty switches map
      expect(command.switches.isEmpty, true);
      expect(command.hasSwitches, false);
    });

    test('command with switches has non-empty switches map', () {
      final command = Command(
        switches: {
          'ios': Command(script: 'flutter build ios'),
          'android': Command(script: 'flutter build android'),
        },
      );

      expect(command.switches.isEmpty, false);
      expect(command.hasSwitches, true);
      expect(command.switches.length, 2);
      expect(command.switches.containsKey('ios'), true);
      expect(command.switches.containsKey('android'), true);
    });

    test('getSwitchInfo returns null for non-existent switch', () {
      final command = Command(switches: {'ios': Command(script: 'flutter build ios')});

      expect(command.getSwitchInfo('android'), null);
    });

    test('getSwitchInfo returns SwitchInfo for existing switch', () {
      final command = Command(
        switches: {'ios': Command(script: 'flutter build ios', description: 'Build for iOS')},
      );

      final info = command.getSwitchInfo('ios');
      expect(info, isNotNull);
      expect(info!.name, 'ios');
      expect(info.description, 'Build for iOS');
      expect(info.command.script, 'flutter build ios');
    });

    test('command with default switch has defaultSwitch set', () {
      final command = Command(
        switches: {
          'ios': Command(script: 'flutter build ios'),
          'android': Command(script: 'flutter build android'),
        },
        defaultSwitch: 'ios',
      );

      expect(command.defaultSwitch, 'ios');
    });

    test('nested switches are accessible', () {
      final command = Command(
        switches: {
          'ios': Command(
            switches: {
              'debug': Command(script: 'flutter build ios --debug'),
              'release': Command(script: 'flutter build ios --release'),
            },
          ),
        },
      );

      final iosCommand = command.switches['ios'];
      expect(iosCommand, isNotNull);
      expect(iosCommand!.hasSwitches, true);
      expect(iosCommand.switches.length, 2);
      expect(iosCommand.switches.containsKey('debug'), true);
      expect(iosCommand.switches.containsKey('release'), true);
    });

    test('switchesInfo is generated from switches', () {
      final command = Command(
        switches: {
          'ios': Command(script: 'flutter build ios', description: 'iOS build'),
          'android': Command(script: 'flutter build android', description: 'Android build'),
        },
      );

      final switchesInfo = command.switchesInfo;
      expect(switchesInfo.length, 2);
      expect(switchesInfo[0].name, 'ios');
      expect(switchesInfo[0].description, 'iOS build');
      expect(switchesInfo[1].name, 'android');
      expect(switchesInfo[1].description, 'Android build');
    });
  });
}
