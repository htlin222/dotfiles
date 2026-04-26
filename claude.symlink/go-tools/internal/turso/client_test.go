package turso

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"
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

// TestCloudRoundTrip exercises the actual Turso cloud DB. Skipped unless
// TURSO_DATABASE_URL and TURSO_AUTH_TOKEN are set (i.e. the user has
// provisioned the DB and stored secrets in pass).
func TestCloudRoundTrip(t *testing.T) {
	url := os.Getenv("TURSO_DATABASE_URL")
	tok := os.Getenv("TURSO_AUTH_TOKEN")
	if url == "" || tok == "" {
		t.Skip("TURSO_DATABASE_URL/TURSO_AUTH_TOKEN not set")
	}

	dir := t.TempDir()
	dbPath := filepath.Join(dir, "prompts.db")

	c, err := OpenReplica(dbPath, url, tok)
	if err != nil || c == nil {
		t.Fatalf("OpenReplica: client=%v err=%v", c, err)
	}
	defer c.Close()

	if err := c.EnsureSchema(); err != nil {
		t.Fatalf("EnsureSchema: %v", err)
	}

	// Insert a uniquely-tagged row so we can find it on cloud.
	tag := fmt.Sprintf("cloud-roundtrip-%d", time.Now().UnixNano())
	if err := c.InsertPrompt("test-host", "rt-session", "/tmp", tag); err != nil {
		t.Fatalf("InsertPrompt: %v", err)
	}

	// Push to cloud.
	if err := c.Sync(); err != nil {
		t.Fatalf("Sync (push): %v", err)
	}

	// Open a fresh replica in a different temp dir, pull, and verify
	// the cloud contains our tagged row.
	dir2 := t.TempDir()
	c2, err := OpenReplica(filepath.Join(dir2, "prompts.db"), url, tok)
	if err != nil || c2 == nil {
		t.Fatalf("OpenReplica (verifier): client=%v err=%v", c2, err)
	}
	defer c2.Close()
	if err := c2.Sync(); err != nil {
		t.Fatalf("Sync (pull): %v", err)
	}

	var count int
	if err := c2.db.QueryRow(
		`SELECT COUNT(*) FROM prompts WHERE prompt = ?`, tag,
	).Scan(&count); err != nil {
		t.Fatalf("verify SELECT: %v", err)
	}
	if count != 1 {
		t.Fatalf("want 1 row matching %q in cloud, got %d", tag, count)
	}
	t.Logf("cloud round-trip ok: %s", tag)
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
