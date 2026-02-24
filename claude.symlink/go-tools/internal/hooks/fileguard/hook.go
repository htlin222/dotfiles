// Package fileguard implements the FileGuard hook to block access to sensitive files.
package fileguard

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// maxScanSize is the maximum file size (1MB) for content scanning.
// Files larger than this are allowed through (fail-open).
const maxScanSize = 1 << 20

// Run executes the file guard hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Only check file-based tools
	if data.ToolName != "Read" && data.ToolName != "Write" && data.ToolName != "Edit" && data.ToolName != "MultiEdit" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Get file paths
	var filePaths []string
	if data.ToolName == "MultiEdit" {
		for _, edit := range data.ToolInput.Edits {
			if edit.FilePath != "" {
				filePaths = append(filePaths, edit.FilePath)
			}
		}
	} else if data.ToolInput.FilePath != "" {
		filePaths = []string{data.ToolInput.FilePath}
	}

	// Check each file path
	for _, filePath := range filePaths {
		if result := checkFile(filePath, &data); result != "" {
			fmt.Println(result)
			return
		}
	}

	// All checks passed
	fmt.Println(protocol.ContinueResponse())
}

// checkFile evaluates a single file path through the 3-tier system.
// Returns a block response string if blocked, empty string if allowed.
func checkFile(filePath string, data *protocol.HookInput) string {
	// Step 1: Exclusions always pass
	if patterns.IsExcluded(filePath) {
		return ""
	}

	// Step 2: Directory block — always block sensitive directories
	if matched, reason := patterns.MatchesDirectoryBlock(filePath); matched {
		return protocol.BlockResponse(
			fmt.Sprintf("BLOCKED: Access to sensitive file denied — %s (%s). Add to .agentignore exceptions if needed.", filePath, reason))
	}

	// Step 3: Always-block — binary/opaque files
	if matched, reason := patterns.MatchesAlwaysBlock(filePath); matched {
		return protocol.BlockResponse(
			fmt.Sprintf("BLOCKED: Access to sensitive file denied — %s (%s). Add to .agentignore exceptions if needed.", filePath, reason))
	}

	// Step 4: Content-scan — text configs scanned for actual secrets
	if patterns.MatchesContentScan(filePath) {
		return scanContent(filePath, data)
	}

	// Step 5: No pattern match — allow
	return ""
}

// scanContent scans file content for secrets. Returns block response if secrets found, empty if clean.
func scanContent(filePath string, data *protocol.HookInput) string {
	var content string

	if data.ToolName == "Write" {
		// For Write operations, scan the content being written
		content = data.ToolInput.Content
	} else {
		// For Read/Edit/MultiEdit, scan existing file on disk
		var err error
		content, err = readFileForScan(filePath)
		if err != nil {
			// Fail-open: can't read → allow (file may not exist, permissions, etc.)
			return ""
		}
	}

	if content == "" {
		return ""
	}

	if hasSensitive, description := patterns.HasSensitiveContent(content); hasSensitive {
		return protocol.BlockResponse(
			fmt.Sprintf("BLOCKED: Sensitive content detected in %s (%s). Add to .agentignore exceptions if needed.", filePath, description))
	}

	// Content is clean — allow
	return ""
}

// readFileForScan reads a file for content scanning.
// Returns content string and error. Fail-open on all errors.
func readFileForScan(filePath string) (string, error) {
	info, err := os.Stat(filePath)
	if err != nil {
		// File doesn't exist — allow
		return "", err
	}

	if info.Size() > maxScanSize {
		// File too large — allow (unlikely to be a small config with secrets)
		return "", fmt.Errorf("file too large: %d bytes", info.Size())
	}

	data, err := os.ReadFile(filePath)
	if err != nil {
		// Can't read — allow
		return "", err
	}

	return string(data), nil
}
