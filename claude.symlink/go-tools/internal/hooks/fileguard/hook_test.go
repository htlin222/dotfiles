package fileguard

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// --- checkFile tests ---

func TestCheckFile_ExcludedFile(t *testing.T) {
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile(".env.example", data)
	if result != "" {
		t.Errorf("excluded file should be allowed, got: %s", result)
	}
}

func TestCheckFile_DirectoryBlock(t *testing.T) {
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile("/home/user/.ssh/config", data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("sensitive directory should be blocked, got: %q", result)
	}
}

func TestCheckFile_AlwaysBlock_PEM(t *testing.T) {
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile("/path/to/server.pem", data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("PEM file should always be blocked, got: %q", result)
	}
}

func TestCheckFile_AlwaysBlock_SQLite(t *testing.T) {
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile("data.sqlite3", data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("sqlite file should always be blocked, got: %q", result)
	}
}

func TestCheckFile_ContentScan_SafeDockerCompose(t *testing.T) {
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "docker-compose.yml")
	safeContent := `version: "3"
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
`
	os.WriteFile(filePath, []byte(safeContent), 0644)

	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile(filePath, data)
	if result != "" {
		t.Errorf("safe docker-compose.yml should be allowed, got: %s", result)
	}
}

func TestCheckFile_ContentScan_DockerComposeWithPassword(t *testing.T) {
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "docker-compose.yml")
	secretContent := `version: "3"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: "SuperSecret123!"
`
	os.WriteFile(filePath, []byte(secretContent), 0644)

	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile(filePath, data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("docker-compose.yml with password should be blocked, got: %q", result)
	}
}

func TestCheckFile_ContentScan_SafeAppsettings(t *testing.T) {
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "appsettings.json")
	safeContent := `{
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  },
  "AllowedHosts": "*"
}`
	os.WriteFile(filePath, []byte(safeContent), 0644)

	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile(filePath, data)
	if result != "" {
		t.Errorf("safe appsettings.json should be allowed, got: %s", result)
	}
}

func TestCheckFile_ContentScan_NonExistentFile(t *testing.T) {
	// Fail-open: non-existent file should be allowed
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile("/nonexistent/path/docker-compose.yml", data)
	if result != "" {
		t.Errorf("non-existent file should be allowed (fail-open), got: %s", result)
	}
}

func TestCheckFile_ContentScan_LargeFile(t *testing.T) {
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "secrets.yaml")
	// Create a file > 1MB
	largeContent := strings.Repeat("key: value\n", 200000)
	os.WriteFile(filePath, []byte(largeContent), 0644)

	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile(filePath, data)
	if result != "" {
		t.Errorf("large file should be allowed (fail-open), got: %s", result)
	}
}

func TestCheckFile_Write_SensitiveContent(t *testing.T) {
	// Write tool scans ToolInput.Content, not file on disk
	data := &protocol.HookInput{
		ToolName: "Write",
		ToolInput: protocol.ToolInput{
			FilePath: "/tmp/docker-compose.yml",
			Content:  `password: "SuperSecret123!"`,
		},
	}
	result := checkFile(data.ToolInput.FilePath, data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("Write with sensitive content should be blocked, got: %q", result)
	}
}

func TestCheckFile_Write_SafeContent(t *testing.T) {
	data := &protocol.HookInput{
		ToolName: "Write",
		ToolInput: protocol.ToolInput{
			FilePath: "/tmp/docker-compose.yml",
			Content: `version: "3"
services:
  web:
    image: nginx:latest
`,
		},
	}
	result := checkFile(data.ToolInput.FilePath, data)
	if result != "" {
		t.Errorf("Write with safe content should be allowed, got: %s", result)
	}
}

func TestCheckFile_NoPatternMatch(t *testing.T) {
	data := &protocol.HookInput{ToolName: "Read"}
	result := checkFile("/project/main.go", data)
	if result != "" {
		t.Errorf("non-sensitive file should be allowed, got: %s", result)
	}
}

// --- readFileForScan tests ---

func TestReadFileForScan_NonExistent(t *testing.T) {
	_, err := readFileForScan("/nonexistent/file.txt")
	if err == nil {
		t.Error("expected error for non-existent file")
	}
}

func TestReadFileForScan_Normal(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "test.yml")
	os.WriteFile(f, []byte("hello: world"), 0644)

	content, err := readFileForScan(f)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if content != "hello: world" {
		t.Errorf("got %q, want %q", content, "hello: world")
	}
}

func TestReadFileForScan_TooLarge(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "big.yml")
	data := make([]byte, maxScanSize+1)
	os.WriteFile(f, data, 0644)

	_, err := readFileForScan(f)
	if err == nil {
		t.Error("expected error for file > maxScanSize")
	}
}

// --- scanContent tests ---

func TestScanContent_EditScansExistingFile(t *testing.T) {
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, ".env")
	os.WriteFile(filePath, []byte("AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCY"), 0644)

	data := &protocol.HookInput{ToolName: "Edit"}
	result := scanContent(filePath, data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("Edit on file with AWS secret should be blocked, got: %q", result)
	}
}

func TestScanContent_WriteScansInputContent(t *testing.T) {
	// Write should scan ToolInput.Content, NOT the file on disk
	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, ".env")
	// File on disk has secrets
	os.WriteFile(filePath, []byte("SAFE=true"), 0644)

	data := &protocol.HookInput{
		ToolName: "Write",
		ToolInput: protocol.ToolInput{
			FilePath: filePath,
			Content:  "ghp_1234567890abcdefghijklmnopqrstuvwxyz",
		},
	}
	result := scanContent(filePath, data)
	if result == "" || !strings.Contains(result, "BLOCKED") {
		t.Errorf("Write with GitHub token should be blocked, got: %q", result)
	}
}

// --- Integration: verify patterns package functions used correctly ---

func TestPatternTiers_NoOverlap(t *testing.T) {
	// Verify always-block files are NOT in content-scan
	alwaysBlockFiles := []string{"id_rsa", "server.pem", "data.sqlite", "wallet.dat", ".pgpass"}
	for _, f := range alwaysBlockFiles {
		if patterns.MatchesContentScan(f) {
			t.Errorf("%q should not match ContentScan (it's AlwaysBlock)", f)
		}
	}
}
