package internal

import "github.com/spf13/cobra"

type PolicyCmd interface {
	GetCmd() *cobra.Command
}
