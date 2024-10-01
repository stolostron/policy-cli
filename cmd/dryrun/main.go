package main

import (
	"os"

	"open-cluster-management.io/config-policy-controller/cmd/dryrun"
)

func main() {
	err := dryrun.Execute()
	if err != nil {
		os.Exit(1)
	}
}
