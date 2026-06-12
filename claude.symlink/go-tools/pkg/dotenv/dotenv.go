// Package dotenv reads secrets from the environment with a fallback to
// the git-ignored .env file next to the go-tools sources
// (~/.claude/go-tools/.env), so keys never live in the repo.
package dotenv

import (
	"os"
	"path/filepath"
	"strings"
)

// File returns the path to the git-ignored .env next to the go-tools
// sources (~/.claude/go-tools/.env).
func File() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return filepath.Join(home, ".claude", "go-tools", ".env")
}

// Get returns the value for key from the process environment, or from
// the go-tools .env file. Empty string when unavailable.
func Get(key string) string {
	if v := strings.TrimSpace(os.Getenv(key)); v != "" {
		return v
	}
	data, err := os.ReadFile(File())
	if err != nil {
		return ""
	}
	return Parse(string(data), key)
}

// Parse extracts the value for key from dotenv-style content.
// Supports comments, "export " prefixes, and single/double quotes.
func Parse(content, key string) string {
	for _, line := range strings.Split(content, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		line = strings.TrimPrefix(line, "export ")
		k, v, ok := strings.Cut(line, "=")
		if !ok || strings.TrimSpace(k) != key {
			continue
		}
		v = strings.TrimSpace(v)
		if len(v) >= 2 {
			if (v[0] == '"' && v[len(v)-1] == '"') || (v[0] == '\'' && v[len(v)-1] == '\'') {
				v = v[1 : len(v)-1]
			}
		}
		return v
	}
	return ""
}
