import 'dart:io';
import 'colors.dart' as colors;

/// Provides interactive terminal menu for selecting a boolean value.
/// This picker is specialized for boolean type parameters with exactly 2 options.
class BooleanPicker {
  /// Shows an interactive menu to select a boolean value.
  /// Returns the selected value ('true' or 'false') or null if cancelled.
  static String? pick(String parameterName, {String? description}) {
    const values = ['false', 'true'];
    int selectedIndex = 0; // Start with false selected (index 0)

    // Helper function to display the menu
    void displayMenu() {
      print('');
      print('Select value for ${colors.blue}$parameterName${colors.reset}:');
      if (description != null && description.isNotEmpty) {
        print('${colors.gray}$description${colors.reset}');
      }
      print('');

      for (var i = 0; i < values.length; i++) {
        final value = values[i];
        final isSelected = i == selectedIndex;

        // Build display string - no trailing spaces for non-selected
        String display = isSelected
            ? '    ${colors.green}$i. $value ✓${colors.reset}'
            : '    $i. $value';

        print(display);
      }

      print('');
      print(
          '${colors.gray}Use arrows to navigate, 0/f for false, 1/t for true, Enter to confirm, Esc to cancel${colors.reset}');
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

      // '0' key (48) or 'f' key (102) or 'F' key (70) - select false
      if (charCode == 48 || charCode == 102 || charCode == 70) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('');
        return 'false';
      }

      // '1' key (49) or 't' key (116) or 'T' key (84) - select true
      if (charCode == 49 || charCode == 116 || charCode == 84) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        print('');
        return 'true';
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
