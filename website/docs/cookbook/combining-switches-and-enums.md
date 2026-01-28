---
sidebar_label: 'Combining Switches and Enums'
---

# Combining Switches and Enums

You can combine switches and enums to create very powerful and flexible commands.

Here is an example of a `tests` command that uses a switch to select between `unit` and `integration` tests, and an enum to select the platform to run the tests on.

```yaml
# commands.yaml

tests: ## Run tests
  switch:
    - unit: ## Run unit tests
      script: |
        echo "Running unit tests on {platform}"
      params:
        optional:
          - platform: '-p, --platform'
            values: [vm, chrome, all]
            default: vm
    - integration: ## Run integration tests
      script: |
        echo "Running integration tests on {platform}"
      params:
        optional:
          - platform: '-p, --platform'
            values: [ios, android, all]
    - default: unit
```

## Running the command

You can now run the `tests` command with different combinations of switches and enums.

```sh
$ tests unit
Running unit tests on vm

$ tests unit -p chrome
Running unit tests on chrome
```

If you run `test integration` without a platform, it will show the interactive picker for the `platform` enum.

```sh
$ tests integration

Select value for platform:

    1. ios
    2. android
    3. all

Press number (1-3) or press Esc to cancel:
```
