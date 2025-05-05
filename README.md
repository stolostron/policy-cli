# `policytools` CLI

The `policytools` CLI is a toolset that helps you manage policies in the multicluster Kubernetes
environments managed by Red Hat Advanced Cluster Management. They're made available through the
[`acm-cli`](https://github.com/stolostron/acm-cli) repository.

## Usage

<!--BEGINHELP-->

```text
Red Hat Advanced Cluster Management Policy Toolset

This toolset helps you manage the policies in multicluster Kubernetes
environments that are managed by Red Hat Advanced Cluster Management.

Usage:
  policytools [command]

Policy Tools Commands:
  dryrun            Locally execute a ConfigurationPolicy
  template-resolver Locally resolve Policy templates

Additional Commands:
  completion        Generate the autocompletion script for the specified shell
  help              Help about any command

Flags:
  -h, --help      help for policytools
  -v, --version   version for policytools

Use "policytools [command] --help" for more information about a command.
```

<!--ENDHELP-->

## Install as a plugin for `oc`

Installing `policytools` as an `oc` plugin is straightforward--copy the binary to a location in the
`PATH` with an `oc-` prefix (or `kubectl-` to install it as a plugin for both `oc` and `kubectl`).
See the
[`kubectl` documentation on plugins](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)
for additional details on plugins.

You can run this Make target command to build the binary from source and install it as an `oc`
plugin to `/usr/local/bin/`:

```bash
make build-oc-plugin
```

Once in the `PATH` with an `oc-` prefix, then the command is available as:

```bash
oc policytools
```

## Build from source

**NOTE:** Some `policytools` subcommands are made available as standalone binaries if the full
`policytools` CLI isn't desired. These are specified in the [`cmd/`](./cmd/) directory.

### Using Go

```bash
go install github.com/stolostron/policy-cli/cmd/policytools@latest
```

**NOTE:** To build a particular release, clone this repository, check out the `release-*` branch,
and run `go install ./cmd/policytools`. This is necessary because previous releases typically have a
`replace` statement in the `go.mod`.

### Using Make targets

To build the `policytools` binary and output it to `build/_output/`:

```bash
make build
```

To build all binaries specified in the `cmd/` directory and output them to `build/_output/`:

```bash
make build-all
```

### Development

See the [Development guide](docs/development.md) for details on developing in this repo.
