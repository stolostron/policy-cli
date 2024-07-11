package main

import (
	"os"

	"github.com/stolostron/policy-cli/pkg/policytools"
)

func main() {
	err := policytools.Execute()
	if err != nil {
		os.Exit(1)
	}
}
