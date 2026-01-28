---
sidebar_label: 'Typed Parameters'
---

# Typed Parameters

`commands_cli` supports a powerful type system for parameters, allowing you to define explicit types for better validation and user experience.

## Supported Types

| Type | Aliases | Description | Example Values |
|------|---------|-------------|----------------|
| `string` | - | Text values (default if not specified) | `"hello"`, `"world"` |
| `boolean` | `bool` | Boolean values | `true`, `false` |
| `integer` | `int` | Whole numbers (no decimal point) | `1`, `-3`, `8080` |
| `double` | - | Decimal numbers (must have decimal point) | `1.0`, `3.14`, `-2.7` |
| `number` | `num` | Any numeric value (integer or decimal) | `1`, `2.0`, `-3`, `-4.7` |

## String Type

The `string` type is the default when no type is specified. It accepts any value.

```yaml
# commands.yaml

greet: ## Greet someone
  script: echo "Hello {name}"
  params:
    optional:
      - name: '-n, --name'
        type: string
```

```sh
$ greet -n World
Hello World

$ greet -n 123
Hello 123
```

## Integer Type

The `integer` type (or `int`) accepts only whole numbers without a decimal point.

```yaml
# commands.yaml

deploy: ## Deploy application
  script: echo "Deploying to port {port}"
  params:
    optional:
      - port: '-p, --port'
        type: int
        default: 3000
```

```sh
$ deploy -p 8080
Deploying to port 8080

$ deploy -p 3.14
❌ Parameter port expects an [integer]
   Got: 3.14 [double]

$ deploy -p abc
❌ Parameter port expects an [integer]
   Got: abc [string]
```

## Double Type

The `double` type accepts only decimal numbers. The value **must** include a decimal point.

```yaml
# commands.yaml

configure: ## Configure timeout
  script: echo "Timeout set to {timeout}s"
  params:
    optional:
      - timeout: '-t, --timeout'
        type: double
        default: 30.5
```

```sh
$ configure -t 60.0
Timeout set to 60.0s

$ configure -t 1
❌ Parameter timeout expects a [double]
   Got: 1 [integer]

$ configure -t abc
❌ Parameter timeout expects a [double]
   Got: abc [string]
```

## Number Type

The `number` type (or `num`) accepts both integers and decimals - any numeric value.

```yaml
# commands.yaml

calculate: ## Calculate with value
  script: echo "Value is {value}"
  params:
    optional:
      - value: '-v, --value'
        type: number
```

```sh
$ calculate -v 42
Value is 42

$ calculate -v 3.14
Value is 3.14

$ calculate -v abc
❌ Parameter value expects a [number]
   Got: abc [string]
```

## Boolean Type

The `boolean` type (or `bool`) accepts only `true` or `false` values.

```yaml
# commands.yaml

build: ## Build with options
  script: echo "verbose={verbose}"
  params:
    optional:
      - verbose: '-v, --verbose'
        type: boolean
```

```sh
$ build -v true
verbose=true

$ build -v false
verbose=false

$ build -v 1
❌ Parameter verbose expects a [boolean]
   Got: 1 [integer]
```

## Boolean Flags (Toggle Behavior)

When a boolean parameter has a default value, using the flag without a value toggles it:

```yaml
# commands.yaml

build: ## Build with options
  script: |
    echo "verbose={verbose} debug={debug}"
  params:
    optional:
      - verbose: '-v, --verbose'
        type: boolean
        default: false
      - debug: '-d, --debug'
        type: boolean
        default: true
```

```sh
$ build
verbose=false debug=true

$ build -v
verbose=true debug=true

$ build --debug
verbose=false debug=false

$ build -v --debug
verbose=true debug=false
```

## Type Validation

`commands_cli` provides helpful error messages when the wrong type is provided. The error shows:
- What type was expected
- What type was received
- An example of correct usage

```sh
$ deploy -p abc
❌ Parameter port expects an [integer]
   Got: abc [string]
💡 Example: deploy -p 3
```

## Help Output

When you run a command with `--help`, the parameter types are displayed:

```sh
$ deploy --help
deploy
params:
  optional:
    port (-p, --port) [integer]
    timeout (-t, --timeout) [double]
```
