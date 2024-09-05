package internal

import (
	runtimeDebug "runtime/debug"
	"slices"

	"github.com/spf13/cobra"
)

var version string

func GetVersion() string {
	if version == "" {
		// Gather the version from the build info
		if info, ok := runtimeDebug.ReadBuildInfo(); ok {
			version = info.Main.Version
		}

		if version == "" || version == "(devel)" {
			version = "Unversioned binary"
		}
	}

	return version
}

// LoadSubCmds processes subcommands and adds them to the parent command.
func LoadSubCmds(parentCmd *cobra.Command, subCmd ...PolicyCmd) {
	// Range over subcommands to handle each one
	for _, cmd := range subCmd {
		subCommand := cmd.GetCmd()

		// Set a default group if none is given
		if subCommand.GroupID == "" {
			subCommand.GroupID = "Policy Tools"
		}

		// Add group if they're missing (this must be complete before adding the subcommand)
		foundGroup := slices.ContainsFunc(
			parentCmd.Groups(),
			func(g *cobra.Group) bool {
				return g.ID == subCommand.GroupID
			})
		if !foundGroup {
			newGroup := &cobra.Group{
				ID:    subCommand.GroupID,
				Title: subCommand.GroupID,
			}
			parentCmd.AddGroup(newGroup)
		}

		// Add subcommand
		parentCmd.AddCommand(subCommand)
	}
}
