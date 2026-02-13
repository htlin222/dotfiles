package config

import (
	_ "embed"
	"encoding/json"
)

//go:embed formatters.json
var formattersJSON []byte

// Formatters maps file extensions to their formatter commands.
// Loaded from formatters.json at compile time via go:embed.
var Formatters map[string][]string

func init() {
	Formatters = make(map[string][]string)
	_ = json.Unmarshal(formattersJSON, &Formatters)
}
