// Package tursosync runs a one-shot Sync() against the local libSQL
// embedded replica, pushing local writes to (and pulling new rows from)
// the configured Turso cloud DB. No-op if Turso env is not set.
package tursosync

import (
	"os"

	"github.com/htlin/claude-tools/internal/turso"
)

func Run() {
	url := os.Getenv("TURSO_DATABASE_URL")
	tok := os.Getenv("TURSO_AUTH_TOKEN")
	if url == "" || tok == "" {
		return
	}
	c, err := turso.OpenReplica(turso.DefaultDBPath(), url, tok)
	if err != nil || c == nil {
		return
	}
	defer c.Close()
	_ = c.Sync()
}
