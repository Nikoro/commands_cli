# CLAUDE.md - Commands CLI

This file provides guidance to Claude Code for understanding and working with this codebase.

## Project Overview

**Commands CLI** is a Dart CLI tool that generates type-safe, project-local command wrappers from YAML definitions. It allows developers to define custom commands in a `commands.yaml` file and automatically creates executable binaries through the Dart pub system.

- **Package**: `commands_cli` (published on pub.dev)
- **Version**: 0.4.1
- **Repository**: https://github.com/Nikoro/commands_cli
- **Documentation**: https://nikoro.github.io/commands_cli/docs
- **SDK**: Dart ^3.0.0 (no external runtime dependencies)

## Architecture

### Execution Flow

```
User runs: commands
    ↓
bin/commands.dart (Entry Point)
    ↓
lib/commands_loader.dart (Parse YAML)
    ↓
lib/command_validator.dart (Validate structure)
    ↓
lib/pubspec_writer.dart (Generate pubspec.yaml)
    ↓
lib/bin_writer.dart (Generate bin files)
    ↓
lib/activator.dart (Run dart pub global activate)
    ↓
~/.generated_commands/ (Generated package with executables)
```

When a user runs a generated command (e.g., `hello`):
```
~/.pub-cache/bin/hello → ~/.generated_commands/bin/hello.dart → lib/run.dart
```

### Key Directories

```
commands_cli/
├── bin/commands.dart          # Main CLI entry point
├── lib/                       # Core library (35+ Dart files)
│   ├── run.dart              # Runtime command execution (648 lines)
│   ├── commands_loader.dart  # Custom YAML parser
│   ├── command_validator.dart # Structure validation
│   ├── activator.dart        # Package activation & warmup
│   ├── param.dart            # Parameter types & validation
│   ├── command.dart          # Command data model
│   ├── enum_picker.dart      # Interactive enum selection
│   ├── switch_picker.dart    # Interactive switch selection
│   ├── boolean_picker.dart   # True/false picker
│   └── options/              # Built-in command handlers
│       ├── help.dart
│       ├── version.dart
│       ├── create.dart
│       ├── list.dart
│       ├── watch.dart
│       ├── deactivate.dart
│       ├── clean.dart
│       └── regenerate.dart
├── test/                      # Unit tests
├── example/                   # Integration tests & example project
│   ├── commands.yaml         # Example command definitions
│   └── test/                 # Integration tests (require global activation)
└── website/                   # Docusaurus documentation
```

### Core Components

| File | Purpose |
|------|---------|
| `lib/run.dart` | Main runtime logic - parses args, resolves switches, validates params, executes scripts |
| `lib/commands_loader.dart` | Custom line-by-line YAML parser (not JSON-based), handles multiline scripts |
| `lib/command_validator.dart` | Validates command structure, detects errors before activation |
| `lib/param.dart` | Parameter model with type validation (string, int, double, bool, number) |
| `lib/reserved_commands.dart` | Detects system command conflicts (ls, test, etc.) |
| `lib/installation_source.dart` | Detects install method (git vs pub.dev), generates dependencies |

## Quick Reference

### Built-in Commands

| Command | Short | Description |
|---------|-------|-------------|
| `commands` | - | Activate/regenerate all commands from commands.yaml |
| `commands --help` | `-h` | Show help |
| `commands --version` | `-v` | Show version & check for updates |
| `commands list` | `-l` | List all defined commands |
| `commands create` | - | Create template commands.yaml |
| `commands watch` | `-w` | Auto-regenerate on YAML changes |
| `commands watch-detached` | `-wd` | Background watch mode |
| `commands watch-kill` | `-wk` | Stop watch process |
| `commands deactivate` | `-d` | Remove specific commands |
| `commands clean` | `-c` | Delete all generated commands |
| `commands regenerate` | `-r` | Clean + reactivate all |
| `commands update` | `-u` | Update to latest version |

### Global Flags

- `--silent`, `-s` - Suppress success messages
- `--exit-error`, `-ee` - Exit with code 1 on errors
- `--exit-warning`, `-ew` - Exit with code 1 on warnings/errors

### Command Definition Syntax (commands.yaml)

```yaml
# Basic command
hello:
  script: echo "Hello World"
  description: Optional description

# Command with parameters
greet:
  script: echo "{greeting} {name}"
  params:
    required:
      - greeting:           # positional param
    optional:
      - name: '-n, --name'  # named param
        default: "World"
        type: string        # string|int|integer|double|bool|boolean|num|number

# Enum parameter (shows interactive picker if no default)
build:
  script: flutter build {platform}
  params:
    optional:
      - platform: '-p, --platform'
        values: [ios, android, web]

# Switch command (nested sub-options)
deploy:
  switch:
    - staging:
        script: ./deploy.sh staging
    - production:
        script: ./deploy.sh production
    - default: staging

# Passthrough arguments
d:
  script: dart ...args

# Override reserved commands
ls:
  override: true
  script: echo "Custom ls"
```

## Git Operations

**IMPORTANT**: Do NOT use GitHub or GitKraken MCP servers for git operations.

Examples:
- Use `git status` instead of MCP server status checks
- Use `git commit -m "message"` instead of MCP commit operations
- Use `git push`, `git pull`, `git branch`, etc. directly in terminal

## Commit Messages

### Conventional Commits Format

All commit messages **MUST** follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types

Use these standard types:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, whitespace, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

#### Scope (Optional)

The scope provides additional context about what part of the codebase is affected:

```
feat(auth): add OAuth2 authentication
fix(api): correct validation error handling
docs(readme): update installation instructions
```

#### Description

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize the first letter
- No period at the end
- Keep it concise but descriptive

#### Examples

Good:
```
feat(auth): add user authentication with JWT
```

Good:
```
fix: correct validation error in login form
```

Good with body:
```
feat(commands): add support for command aliases

Allow users to define custom aliases for frequently used commands.
This improves usability and reduces typing for common operations.
```

Good with breaking change:
```
feat(api)!: change authentication endpoint structure

BREAKING CHANGE: The /auth endpoint now requires a different request format.
Update client code to use the new { email, password } structure.
```

Bad:
```
Added new feature
```

Bad:
```
Fix bug.
```

Bad:
```
Updated some stuff
```

### What to Avoid

**DO NOT include** any of the following in commit messages:

- References to AI models (Claude, GPT, etc.)
- "Generated with Claude Code" or similar branding
- Co-authored-by attributions to AI assistants
- Any mentions of AI assistance in the commit process
- Vague descriptions like "updates", "changes", "fixes"
- Emoji (unless part of established team convention)

Bad:
```
feat(auth): add user authentication

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Bad:
```
fix: bug fix (created with AI assistance)
```

### Rationale

Following Conventional Commits:
- Creates a clear, standardized git history
- Enables automatic changelog generation
- Makes it easier to understand the nature of changes
- Improves collaboration and code review processes
- Allows for semantic versioning automation

Commit messages should focus on **what** changed and **why**, not the tools used to create the changes.

## Testing Workflow

When implementing new features, refactoring, or making any changes, follow this complete testing workflow:

### 1. Run Unit Tests

First, run unit tests in the root `test/` folder to verify core functionality:

```bash
dart test --test-randomize-ordering-seed=random
```

### 2. Run Integration Tests (CRITICAL)

Integration tests are located in `example/test/` and are essential to verify the complete workflow.

**To run integration tests, you MUST:**

1. **Push changes to your working branch:**
   ```bash
   git push origin <branch-name>
   ```

2. **Activate the package globally from your branch:**
   ```bash
   dart pub global activate --source git https://github.com/Nikoro/commands_cli.git --git-ref <branch-name>
   ```

   Note: By default (without `--git-ref`), this activates from the `main` branch. Use `--git-ref` to specify a different branch.

3. **Clean all previously generated commands:**
   ```bash
   commands clean
   ```

4. **Activate all commands:**
   ```bash
   cd example && commands
   ```

5. **Run the integration tests:**
   ```bash
   dart test
   ```

**IMPORTANT**: Integration tests in `example/test/` require the package to be globally activated. Do not skip this step or the tests may fail or not reflect the actual changes.

## Code Patterns

### No External Dependencies

The project uses only Dart standard library (`dart:io`, `dart:async`, `dart:convert`). This is intentional for faster startup and reduced complexity.

### Custom YAML Parser

`commands_loader.dart` uses a custom line-by-line parser (not JSON-based) to:
- Maintain indentation context for nested switches
- Handle multiline scripts with `|`
- Capture YAML comments for help generation

### Interactive Pickers

The picker classes (`enum_picker.dart`, `switch_picker.dart`, `boolean_picker.dart`) use low-level stdin control:
- Raw mode for arrow key detection
- Real-time menu redrawing
- ESC to cancel

### Validation Strategy

Validation errors are collected (not early-exit) and reported together at the end for better UX.

## Generated Files Location

Commands are generated to `~/.generated_commands/`:
```
~/.generated_commands/
├── pubspec.yaml          # Generated with commands_cli dependency
├── bin/                  # One .dart file per command
│   ├── hello.dart
│   └── ...
└── .dart_tool/           # Dart snapshots for fast execution
```

Executables are installed to `~/.pub-cache/bin/`.

## Common Tasks

### Adding a New Built-in Command

1. Create handler in `lib/options/new_command.dart`
2. Export from `lib/options/options.dart`
3. Add flag handling in `bin/commands.dart`
4. Add unit tests in `test/`

### Adding a New Parameter Type

1. Update `lib/param.dart` with type validation logic
2. Update `lib/run.dart` for runtime parsing
3. Update `lib/command_validator.dart` for validation
4. Add tests in `test/param_test.dart`

### Modifying YAML Parsing

The YAML parser in `lib/commands_loader.dart` is custom-built. When modifying:
- Maintain line-by-line parsing approach
- Handle indentation context carefully for nested structures
- Preserve comment extraction for help generation
