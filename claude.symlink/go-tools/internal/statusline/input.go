// Package statusline implements the Claude Code statusline.
package statusline

import (
	"encoding/json"
	"io"
	"os"

	"github.com/htlin/claude-tools/internal/protocol"
)

// ParseInput reads and parses statusline JSON input from stdin.
func ParseInput() (*protocol.StatuslineInput, error) {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return nil, err
	}

	var data protocol.StatuslineInput
	if err := json.Unmarshal(input, &data); err != nil {
		return nil, err
	}

	return &data, nil
}
