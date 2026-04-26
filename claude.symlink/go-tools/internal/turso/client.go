// Package turso wraps libSQL embedded-replica access for prompt capture.
// Writes are local-first; Sync() pushes/pulls against the cloud DB.
package turso

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/tursodatabase/go-libsql"
)

const schema = `
CREATE TABLE IF NOT EXISTS prompts (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    ts          REAL    NOT NULL DEFAULT (unixepoch('now','subsec')),
    device_id   TEXT    NOT NULL,
    session_id  TEXT,
    cwd         TEXT,
    prompt      TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_prompts_ts        ON prompts(ts DESC);
CREATE INDEX IF NOT EXISTS idx_prompts_device_ts ON prompts(device_id, ts DESC);
`

type Client struct {
	db        *sql.DB
	connector *libsql.Connector
}

// OpenReplica opens a libSQL embedded replica at dbPath that syncs to syncURL.
// Returns (nil, nil) if syncURL or token is empty so callers can treat it as
// "Turso not configured, skip silently".
func OpenReplica(dbPath, syncURL, token string) (*Client, error) {
	if syncURL == "" || token == "" {
		return nil, nil
	}
	if err := os.MkdirAll(filepath.Dir(dbPath), 0o755); err != nil {
		return nil, fmt.Errorf("mkdir replica dir: %w", err)
	}
	conn, err := libsql.NewEmbeddedReplicaConnector(dbPath, syncURL,
		libsql.WithAuthToken(token),
	)
	if err != nil {
		return nil, fmt.Errorf("libsql connector: %w", err)
	}
	db := sql.OpenDB(conn)
	return &Client{db: db, connector: conn}, nil
}

// OpenLocal opens a pure-local libSQL DB. Used in tests.
func OpenLocal(dbPath string) (*Client, error) {
	if err := os.MkdirAll(filepath.Dir(dbPath), 0o755); err != nil {
		return nil, fmt.Errorf("mkdir db dir: %w", err)
	}
	db, err := sql.Open("libsql", "file:"+dbPath)
	if err != nil {
		return nil, err
	}
	return &Client{db: db}, nil
}

func (c *Client) Close() error {
	err := c.db.Close()
	if c.connector != nil {
		_ = c.connector.Close()
	}
	return err
}

func (c *Client) EnsureSchema() error {
	_, err := c.db.Exec(schema)
	return err
}

func (c *Client) InsertPrompt(deviceID, sessionID, cwd, prompt string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_, err := c.db.ExecContext(ctx,
		`INSERT INTO prompts(device_id, session_id, cwd, prompt) VALUES (?,?,?,?)`,
		deviceID, sessionID, cwd, prompt,
	)
	return err
}

// Sync pushes local writes to and pulls remote writes from the cloud.
// No-op on local-only clients.
func (c *Client) Sync() error {
	if c.connector == nil {
		return nil
	}
	_, err := c.connector.Sync()
	return err
}

func (c *Client) countRows() (int, error) {
	var n int
	err := c.db.QueryRow(`SELECT COUNT(*) FROM prompts`).Scan(&n)
	return n, err
}

// DefaultDBPath returns the canonical local replica path.
func DefaultDBPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".claude", "state", "prompts.db")
}
