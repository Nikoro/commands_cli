import 'dart:io';
import 'package:commands_cli/param.dart';
import 'colors.dart' as colors;

/// Provides interactive terminal menu for selecting an enum value.
class EnumPicker {
  /// Shows an interactive menu to select an enum value for the given parameter.
  /// Returns the selected value or null if cancelled.
  static String? pick(Param param, String parameterName) {
    if (!param.isEnum || param.values == null || param.values!.isEmpty) {
      return null;
    }

    final values = param.values!;
    int selectedIndex = 0; // Currently selected option (0-based)

    // Calculate max value length for alignment
    int maxValueLength = 0;
    for (final value in values) {
      if (value.length > maxValueLength) {
        maxValueLength = value.length;
      }
    }

    // Helper function to display the menu
    void displayMenu() {
      print('');
      print('Select value for ${colors.blue}$parameterName${colors.reset}:');
      if (param.description != null && param.description!.isNotEmpty) {
        print('${colors.gray}${param.description}${colors.reset}');
      }
      print('');

      for (var i = 0; i < values.length; i++) {
        final value = values[i];
        final number = i + 1;
        final isSelected = i == selectedIndex;
        final checkMark = isSelected ? ' ✓' : '  '; // Always 2 chars width

        // Pad value to align everything
        final paddedValue = value.padRight(maxValueLength);

        // Build display string
        String display = isSelected
            ? '    ${colors.green}$number. $paddedValue$checkMark${colors.reset}'
            : '    $number. $paddedValue$checkMark';

        print(display);
      }

      print('');
      print('${colors.gray}Press number (1-${values.length}) or press Esc to cancel:${colors.reset}');
    }

    // Display initial menu
    displayMenu();

    // Enable raw mode to detect arrow keys and ESC
    stdin.echoMode = false;
    stdin.lineMode = false;

    while (true) {
      final charCode = stdin.readByteSync();

      // ESC key (27) - check if it's part of arrow key sequence
      if (charCode == 27) {
        // Sleep briefly to see if more bytes are coming (for arrow keys)
        sleep(Duration(milliseconds: 10));

        // Check if there's more input (arrow keys send ESC[A/B/C/D)
        if (stdin.hasTerminal) {
          try {
            // Try to read next byte without blocking
            final bytesAvailable = stdin.readByteSync();

            if (bytesAvailable == 91) {
              // '[' character - this is an arrow key sequence
              final arrowChar = stdin.readByteSync();

              // Arrow Up (65 = 'A')
              if (arrowChar == 65) {
                selectedIndex = (selectedIndex - 1 + values.length) % values.length;
                // Clear screen and redraw
                _clearScreen(values.length + 5);
                displayMenu();
                continue;
              }

              // Arrow Down (66 = 'B')
              if (arrowChar == 66) {
                selectedIndex = (selectedIndex + 1) % values.length;
                // Clear screen and redraw
                _clearScreen(values.length + 5);
                displayMenu();
                continue;
              }
            }
          } catch (e) {
            // No more bytes available - it's just ESC key
          }
        }

        // Just ESC key - cancel
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('\n${colors.yellow}Cancelled${colors.reset}');
        return null;
      }

      // Enter key (10 or 13) - execute selected option
      if (charCode == 10 || charCode == 13) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('');
        return values[selectedIndex];
      }

      // Number keys (49-57 correspond to '1'-'9')
      if (charCode >= 49 && charCode <= 57) {
        final number = charCode - 48; // Convert to 1-9
        if (number >= 1 && number <= values.length) {
          stdin.echoMode = true;
          stdin.lineMode = true;
          print('');
          return values[number - 1];
        }
      }
    }
  }

  /// Clears the specified number of lines from the terminal
  static void _clearScreen(int lines) {
    for (var i = 0; i < lines; i++) {
      stdout.write('\x1B[1A'); // Move cursor up one line
      stdout.write('\x1B[2K'); // Clear entire line
    }
    stdout.write('\r'); // Move cursor to start of line
  }
}
