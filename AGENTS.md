# Agent Instructions

## Git Operations

**IMPORTANT**: Do NOT use GitHub or GitKraken MCP servers for git operations.

Examples:
- Use `git status` instead of MCP server status checks
- Use `git commit -m "message"` instead of MCP commit operations
- Use `git push`, `git pull`, `git branch`, etc. directly in terminal

## Testing Workflow

When implementing new features, refactoring, or making any changes, follow this complete testing workflow:

### 1. Run Unit Tests
First, run unit tests in the root `test/` folder to verify core functionality.

### 2. Run Integration Tests (CRITICAL)
Integration tests are located in `example/test/` and are essential to verify the complete workflow.

**To run integration tests, you MUST:**

1. **Push changes to your working branch:**
   ```sh
   git push origin <branch-name>
   ```

2. **Activate the package globally from your branch:**
   ```sh
   dart pub global activate --source git https://github.com/Nikoro/commands_cli.git --git-ref <branch-name>
   ```
   
   Note: By default (without `--git-ref`), this activates from the `main` branch. Use `--git-ref` to specify a different branch.

3. **Clean all previously generated commands:**
   ```sh
   commands clean
   ```   

4. **Activate all commands:**
   ```sh
   cd example && commands
   ```

5. **Run the integration tests:**
   ```sh
   dart test
   ```

**IMPORTANT**: Integration tests in `example/test/` require the package to be globally activated. Do not skip this step or the tests may fail or not reflect the actual changes.
