# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the `policytools` CLI for Red Hat Advanced Cluster Management, a toolset for managing policies in multicluster Kubernetes environments. The CLI is built on the Cobra framework and provides subcommands for policy operations like dry-running ConfigurationPolicies and resolving Policy templates.

## Build Commands

- `make build` - Build the main `policytools` binary to `build/_output/`
- `make build-all` - Build all binaries in `cmd/*` directory to `build/_output/`
- `make build-release` - Build for multiple architectures (requires clean git state)
- `make build-oc-plugin` - Build and install as `oc` plugin to `/usr/local/bin/oc-policytools`

## Testing

- `./test/test.sh --validate-readme` - Validate that README.md help section matches `policytools --help` output
- Run this after the binary is built with `make build`

## Code Architecture

### Command Structure
- Main CLI entry point: `cmd/policytools/main.go` calls `pkg/policytools/policytools.go`
- Subcommands are dynamically loaded using the `PolicyCmd` interface defined in `internal/types.go`
- Each subcommand must implement `GetCmd() *cobra.Command` and be added to `LoadSubCmds()` in `pkg/policytools/policytools.go`

### Key Components
- `internal/helpers.go` - Contains version handling and subcommand loading logic
- `pkg/policytools/policytools.go` - Main command structure and subcommand registration
- Subcommands come from external packages:
  - `github.com/stolostron/go-template-utils/v7/cmd/template-resolver/utils` for template-resolver
  - `open-cluster-management.io/config-policy-controller/pkg/dryrun` for dryrun

### Adding New Subcommands
1. Create a package that implements the `PolicyCmd` interface
2. Add it to the `LoadSubCmds()` call in `pkg/policytools/policytools.go`
3. For standalone CLIs, create a new directory in `cmd/` with an `Execute()` function

## Development Notes

- Built with Go 1.23.0
- Uses Cobra CLI framework with structured approach (no global variables or init functions)
- Version is set via ldflags during build: `-X 'github.com/stolostron/policy-cli/internal.version=$(GIT_VERSION)'`
- The project follows a modular design where subcommands can be built as standalone binaries