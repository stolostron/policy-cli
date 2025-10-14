# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The `policytools` CLI is a toolset for managing policies in multicluster Kubernetes environments managed by Red Hat Advanced Cluster Management (RHACM). This repository is part of the Open Cluster Management (OCM) governance, risk, and compliance (GRC) ecosystem.

The CLI is distributed through the [`acm-cli`](https://github.com/stolostron/acm-cli) repository and can be installed as an `oc` or `kubectl` plugin.

## Build and Development Commands

### Building
```bash
# Build the main policytools binary (output to build/_output/)
make build

# Build all binaries in cmd/* (output to build/_output/)
make build-all

# Build and install as oc plugin to /usr/local/bin/
make build-oc-plugin

# Build release binaries for multiple architectures
make build-release
```

### Code Quality
```bash
# Format code with gofmt
make fmt

# Lint code with golangci-lint
make lint

# Validate README.md matches CLI help output
make validate-readme
```

### Testing
Tests are run via `test/test.sh` script. The main test validates that the README.md help text matches the actual CLI output:
```bash
./test/test.sh --validate-readme
```

### Using Go Directly
```bash
# Install from source
go install github.com/stolostron/policy-cli/cmd/policytools@latest

# For release branches, clone and run:
go install ./cmd/policytools
```

## Architecture

### Cobra Framework Structure

The CLI is built on [Cobra](https://github.com/spf13/cobra) but avoids the typical Cobra pattern of package-level variables and `init()` functions. Instead, it uses:
- Scoped variables
- Structs to pass arguments
- The `PolicyCmd` interface for all commands

### Directory Structure

- **`cmd/`**: Entry points for binaries. Each subfolder is a standalone CLI that can be built.
  - `cmd/policytools/`: Main policytools binary
  - `cmd/dryrun/`: Standalone dryrun binary
  - `cmd/template-resolver/`: Standalone template-resolver binary

- **`pkg/`**: Command implementations. Each subfolder is a subcommand.
  - `pkg/policytools/`: Root command that loads all subcommands

- **`internal/`**: Shared utilities and interfaces
  - `internal/types.go`: Defines the `PolicyCmd` interface
  - `internal/helpers.go`: Contains `LoadSubCmds()` and version management

- **`test/`**: Test scripts for validation

- **`build/`**: Build output directory and common Makefiles

### Command Registration Flow

1. All commands must implement the `PolicyCmd` interface defined in `internal/types.go`:
   ```go
   type PolicyCmd interface {
       GetCmd() *cobra.Command
   }
   ```

2. Subcommands are registered in `pkg/policytools/policytools.go` via `internal.LoadSubCmds()`:
   ```go
   internal.LoadSubCmds(
       policyCmd,                            // Root command
       &templateresolver.TemplateResolver{}, // template-resolver subcommand
       &dryrun.DryRunner{},                  // dryrun subcommand
   )
   ```

3. The `LoadSubCmds()` function (in `internal/helpers.go`):
   - Calls `GetCmd()` on each subcommand
   - Sets default group ID if none exists
   - Creates command groups as needed
   - Adds subcommands to the parent

4. Subcommands can have their own nested subcommands loaded in the same fashion during their `GetCmd()` implementation.

### Adding New Subcommands

To add a new subcommand:
1. Create a new package in `pkg/` (e.g., `pkg/mycommand/`)
2. Implement the `PolicyCmd` interface with a `GetCmd()` method
3. Add the subcommand to `internal.LoadSubCmds()` in `pkg/policytools/policytools.go`
4. Optionally create a standalone binary in `cmd/mycommand/` if it should be available separately

### Versioning

Version information is injected at build time via Go linker flags:
- `GO_LDFLAGS` sets `github.com/stolostron/policy-cli/internal.version`
- Falls back to Git describe, branch+SHA, or build info
- Retrieved via `internal.GetVersion()`

## Key Subcommands

- **`dryrun`**: Locally execute a ConfigurationPolicy (from `open-cluster-management.io/config-policy-controller`)
- **`template-resolver`**: Locally resolve Policy templates (from `github.com/stolostron/go-template-utils`)

Both subcommands are imported from external packages and integrated via the `PolicyCmd` interface.

## Contributing

All commits must be signed off with DCO (Developer Certificate of Origin):
```bash
git commit --signoff
```

Before submitting a PR, run:
```bash
make fmt
make lint
make test
```

## Dependencies

- Go 1.24.0+
- Key dependencies:
  - `github.com/spf13/cobra` - CLI framework
  - `github.com/stolostron/go-template-utils/v7` - Template resolution
  - `open-cluster-management.io/config-policy-controller` - Policy execution
