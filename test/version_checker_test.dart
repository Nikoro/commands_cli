import 'package:commands_cli/version_checker.dart';
import 'package:test/test.dart';

void main() {
  group('VersionCheckResult', () {
    group('hasNewerVersion', () {
      test('returns true when latest version is newer', () {
        final result = VersionCheckResult(
          currentVersion: '1.0.0',
          latestVersion: '1.0.1',
          changelogUrl: 'https://example.com/changelog',
        );

        expect(result.hasNewerVersion, isTrue);
      });

      test('returns false when latest version is same', () {
        final result = VersionCheckResult(
          currentVersion: '1.0.0',
          latestVersion: '1.0.0',
          changelogUrl: 'https://example.com/changelog',
        );

        expect(result.hasNewerVersion, isFalse);
      });

      test('returns false when latest version is older', () {
        final result = VersionCheckResult(
          currentVersion: '1.0.1',
          latestVersion: '1.0.0',
          changelogUrl: 'https://example.com/changelog',
        );

        expect(result.hasNewerVersion, isFalse);
      });

      test('returns false when latest version is null', () {
        final result = VersionCheckResult(
          currentVersion: '1.0.0',
          latestVersion: null,
          changelogUrl: 'https://example.com/changelog',
        );

        expect(result.hasNewerVersion, isFalse);
      });
    });

    group('version comparison via hasNewerVersion', () {
      test('correctly detects newer major versions', () {
        final result = VersionCheckResult(currentVersion: '1.0.0', latestVersion: '2.0.0');
        expect(result.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '2.0.0', latestVersion: '1.0.0');
        expect(result2.hasNewerVersion, isFalse);
      });

      test('correctly detects newer minor versions', () {
        final result = VersionCheckResult(currentVersion: '1.0.0', latestVersion: '1.1.0');
        expect(result.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '1.1.0', latestVersion: '1.0.0');
        expect(result2.hasNewerVersion, isFalse);
      });

      test('correctly detects newer patch versions', () {
        final result = VersionCheckResult(currentVersion: '1.0.0', latestVersion: '1.0.1');
        expect(result.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '1.0.1', latestVersion: '1.0.0');
        expect(result2.hasNewerVersion, isFalse);
      });

      test('correctly handles multi-digit version parts', () {
        final result = VersionCheckResult(currentVersion: '1.9.0', latestVersion: '1.10.0');
        expect(result.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '1.10.0', latestVersion: '1.9.0');
        expect(result2.hasNewerVersion, isFalse);

        final result3 = VersionCheckResult(currentVersion: '0.99.99', latestVersion: '1.0.0');
        expect(result3.hasNewerVersion, isTrue);
      });

      test('correctly handles different version lengths', () {
        final result = VersionCheckResult(currentVersion: '1.0', latestVersion: '1.0.0');
        expect(result.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '1.0.0', latestVersion: '1.0');
        expect(result2.hasNewerVersion, isFalse);
      });

      test('handles complex version comparisons', () {
        final result1 = VersionCheckResult(currentVersion: '0.1.0', latestVersion: '0.2.0');
        expect(result1.hasNewerVersion, isTrue);

        final result2 = VersionCheckResult(currentVersion: '0.2.1', latestVersion: '0.2.0');
        expect(result2.hasNewerVersion, isFalse);

        final result3 = VersionCheckResult(currentVersion: '1.0.0', latestVersion: '0.99.99');
        expect(result3.hasNewerVersion, isFalse);
      });
    });
  });

  group('VersionCheckResult properties', () {
    test('stores current version correctly', () {
      final result = VersionCheckResult(
        currentVersion: '1.2.3',
        latestVersion: '1.2.4',
        changelogUrl: 'https://example.com/changelog',
      );

      expect(result.currentVersion, equals('1.2.3'));
    });

    test('stores latest version correctly', () {
      final result = VersionCheckResult(
        currentVersion: '1.2.3',
        latestVersion: '1.2.4',
        changelogUrl: 'https://example.com/changelog',
      );

      expect(result.latestVersion, equals('1.2.4'));
    });

    test('stores changelog URL correctly', () {
      final result = VersionCheckResult(
        currentVersion: '1.2.3',
        latestVersion: '1.2.4',
        changelogUrl: 'https://example.com/changelog',
      );

      expect(result.changelogUrl, equals('https://example.com/changelog'));
    });

    test('allows null latest version', () {
      final result = VersionCheckResult(
        currentVersion: '1.2.3',
        latestVersion: null,
        changelogUrl: 'https://example.com/changelog',
      );

      expect(result.latestVersion, isNull);
    });

    test('allows null changelog URL', () {
      final result = VersionCheckResult(
        currentVersion: '1.2.3',
        latestVersion: '1.2.4',
        changelogUrl: null,
      );

      expect(result.changelogUrl, isNull);
    });
  });
}
