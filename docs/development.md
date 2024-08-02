# Development guide

## Structure

The `policytools` CLI is built on the [Cobra](https://github.com/spf13/cobra) framework. While the
default there is to liberally use package variables and `init()` functions, this has been structured
to use scoped variables, passing args via structs. This lends itself to greater predictability and
readability.

CLIs to be built live in the `cmd/` directory and call the `Execute()` function to packages defined
in the `pkg/` directory, each of which contain a `GetCmd()` function that builds the command,
enforced through the [`PolicyCmd` interface](../internal/types.go). Each subfolder in the `pkg/`
directory is a subcommand and must be added to the list of subcommands in
[`pkg/policytools/policytools.go`](../pkg/policytools/policytools.go) inside of the
`internal.LoadSubCmds()` function there. Similarly, subcommands of subcommands must be loaded during
`GetCmd()` to be added in the same fashion.

The intention is that all commands in `pkg/` be subcommands of `policytools`, but any CLI that could
be useful by itself can implement an `Execute()` function and be added to the `cmd/` directory to be
built. `make build-all` dynamically builds all folders that exist there.

## Make targets

```
build
  Build the `policytools` binary in `cmd/policytools/` and output to `build/_output/`
build-release
  Build the `policytools` binary for various architectures and output to `build/_output/`
build-all
  Build all binaries in `cmd/*` and output to `build/_output/`
fmt
  Run gofmt against code
lint
  Lint code with golangci-lint
test
  Execute tests to verify binary output
```
