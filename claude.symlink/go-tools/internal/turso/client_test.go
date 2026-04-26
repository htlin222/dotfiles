package turso

import (
	"os"
	"path/filepath"
	"testing"
)

func TestInsertPromptLocalOnly(t *testing.T) {
	dir := t.TempDir()
	dbPath := filepath.Join(dir, "prompts.db")

	c, err := OpenLocal(dbPath)
	if err != nil {
		t.Fatalf("OpenLocal: %v", err)
	}
	defer c.Close()

	if err := c.EnsureSchema(); err != nil {
		t.Fatalf("EnsureSchema: %v", err)
	}

	if err := c.InsertPrompt("dev1", "sess-abc", "/tmp", "hello world"); err != nil {
		t.Fatalf("InsertPrompt: %v", err)
	}

	count, err := c.countRows()
	if err != nil {
		t.Fatalf("countRows: %v", err)
	}
	if count != 1 {
		t.Fatalf("want 1 row, got %d", count)
	}

	if _, err := os.Stat(dbPath); err != nil {
		t.Fatalf("expected db file at %s: %v", dbPath, err)
	}
}

func TestOpenReplicaSkipsWhenUnconfigured(t *testing.T) {
	c, err := OpenReplica("/tmp/should-not-create.db", "", "")
	if err != nil {
		t.Fatalf("expected nil error when unconfigured, got: %v", err)
	}
	if c != nil {
		t.Fatalf("expected nil client when unconfigured, got: %v", c)
	}
}

func TestOpenAutoFallsBackToLocal(t *testing.T) {
	dir := t.TempDir()
	dbPath := filepath.Join(dir, "prompts.db")

	// No URL/token -> should still produce a working local client.
	c, err := Open(dbPath, "", "")
	if err != nil || c == nil {
		t.Fatalf("Open: want client, got (%v, %v)", c, err)
	}
	defer c.Close()

	if err := c.EnsureSchema(); err != nil {
		t.Fatalf("EnsureSchema: %v", err)
	}
	if err := c.InsertPrompt("dev1", "sess", "/tmp", "auto-fallback"); err != nil {
		t.Fatalf("InsertPrompt: %v", err)
	}
	// Sync() must be a no-op on the local-only path.
	if err := c.Sync(); err != nil {
		t.Fatalf("Sync on local-only: %v", err)
	}
}
