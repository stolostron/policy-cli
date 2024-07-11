package policytools

import (
	"github.com/spf13/cobra"
	templateresolver "github.com/stolostron/go-template-utils/v6/cmd/template-resolver/utils"

	"github.com/stolostron/policy-cli/internal"
)

// acmCmd represents the base command when called without any subcommands
type Cmd struct{}

func (a Cmd) GetCmd() *cobra.Command {
	policyCmd := &cobra.Command{
		Use:   "policytools",
		Short: "ACM Policy Toolset",
		Long: `ACM Policy Toolset

This toolset helps you manage the policies in multicluster Kubernetes
environments managed by Advanced Cluster Management.`,
	}

	// Load subcommands
	internal.LoadSubCmds(
		// Root command
		policyCmd, // policytools
		// Subcommands
		&templateresolver.TemplateResolver{}, // template-resolver
	)

	return policyCmd
}

// Execute loads subcommands and runs the `acm` command.
func Execute() error {
	policytoolsCmd := Cmd{}.GetCmd()

	return policytoolsCmd.Execute()
}
