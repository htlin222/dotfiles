// claude-statusline is the Claude Code statusline command.
package main

import (
	"os"

	"github.com/htlin/claude-tools/internal/statusline"
)

func main() {
	data, err := statusline.ParseInput()
	if err != nil {
		os.Exit(1)
	}

	statusline.Render(data)
}
