package main

import (
	"os"

	templateresolver "github.com/stolostron/go-template-utils/v7/cmd/template-resolver/utils"
)

func main() {
	err := templateresolver.Execute()
	if err != nil {
		os.Exit(1)
	}
}
