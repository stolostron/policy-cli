package main

import (
	"os"

	"github.com/stolostron/policy-cli/pkg/templateresolver"
)

func main() {
	err := templateresolver.Execute()
	if err != nil {
		os.Exit(1)
	}
}
