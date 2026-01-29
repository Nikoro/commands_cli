## 0.4.0 - 2026-01-28

### Added
- Typed parameter support with `integer` type (`int` alias) and strict validation
- Typed parameter support with `number` type (`num` alias) for numeric values
- Typed parameter support with `double` type for floating-point values
- Typed parameter support with `boolean` type (`bool` alias) with improved validation
- Specialized `BooleanPicker` for boolean type parameters with interactive selection
- Typed enum validation for parameters with explicit type specification
- Support for `values:` without brackets for boolean params
- Default values now styled with bold orange instead of wrapped in quotes
- Docusaurus documentation website with GitHub Pages deployment

### Changed
- Removed type inference - explicit type specification now required
- Improved enum validation error messages with single-line output
- Alternative switch names now formatted as `or <alias1>, <alias2>` instead of `or: [aliases]`
- Report all missing positional params together including enums
- Include enum values and param descriptions in switch help output
- Optimized integration test suite performance

### Fixed
- Accept any valid boolean when type is explicitly boolean
- Show type-specific errors for boolean-typed enums
- Use strict integer validation for enum values and defaults
- Use strict double validation for typed enum values
- Use correct article 'an' for integer type in error messages
- Strip quotes from enum string values for validation and display
- Strip quotes from enum values in interactive picker
- Preserve param order in missing params error
- Check missing params before showing enum picker
- Check params+switch conflict before script+switch
- Include all command names in padding calculation
- Validate default values at runtime for typed parameters
- Handle type aliases (num, int, bool) in runtime validation
- Support param description without colon
- Exit params context when encountering switch keyword
- Finalize param immediately after values are processed
- Handle numeric equivalence in enum value validation
- Store validation errors instead of exit(1) during activation

---
## 0.3.2 - 2025-12-15

### Fixed
- Stream regenerate output in real-time for update command

---
## 0.3.1 - 2025-12-15

### Added
- Progress percentage indicator during warmup and regeneration

### Fixed
- Keep cursor on new line during progress updates in regenerate

---
## 0.3.0 - 2025-12-15

### Added
- Update check: Notifies users when a new version is available and provides a clickable changelog link
- `regenerate` command: Cleans and reactivates all commands in one step
- `--silent`, `--exit-error`, and `--exit-warning` flags for improved CLI control
- Auto-regenerate after successful update
- String.containsAny extension for cleaner string checks
- Tests for version checking and enum picker in interactive cases

### Changed
- Help output: Reordered and grouped options for clarity
- Treat `--silent` and `--exit` options as regular options in help
- Improved enum validation error messages
- Improved update logic to match generated commands dependency to global installation

### Fixed
- Correctly reactivate individual commands after regeneration
- Remove leading space in help examples output
- Allow enum picker for required positional params without defaults
- Improve error messages for invalid enum values
- Correct padding in help output test expectations

### Documentation
- Expanded AGENTS.md and CLAUDE.md with commit and workflow rules
- Clarified help and option descriptions

---
## 0.2.1 - 2024-12-08

### Changed
- Rename `logo/` directory to `assets/` for more general media storage
- Update documentation to reference new assets path

### Added
- Add demo.webp to showcase CLI functionality in README

## 0.2.0 - 2025-12-07

### Features
- **Update Command**: Add new `--update` (`-u`) option that intelligently updates commands_cli
  - Auto-detects global vs local installation context
  - Runs `dart pub global activate` for global installations
  - Runs `dart pub upgrade` for local dependencies
  - Preserves installation source (git vs pub.dev) during updates

### Improvements
- **Update Logic**: Simplify git URL handling and improve source detection
  - Use hardcoded public repository URL for git updates
  - Enhanced source detection with regex-based parsing for commands_cli package entry

### Documentation
- Add AGENTS.md with testing workflow instructions
  - Git operations guidelines
  - Integration test workflow requiring global package activation
  - Instructions for activating from specific git branches using `--git-ref` flag
- Expand package description in pubspec.yaml
- Add package topics for better discoverability (cli, makefile, commands, task-runner, script-manager)
- Update repository and issue tracker URLs
- Update pub.dev and GitHub Actions badge URLs

### Testing
- Add comprehensive test coverage for help option flags
- Update integration tests to accept both git and pub.dev update messages

### CI/CD
- Add concurrency control to automatically cancel previous workflow runs

## 0.1.0 - 2025-12-07

Initial release 🎉
