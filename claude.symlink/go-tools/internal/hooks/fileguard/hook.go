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

// Run executes the file guard hook. Allow = exit 0 with no output.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	// Get file paths. Codex reports patch edits as apply_patch with the
	// patch body in tool_input.command.
	var filePaths []string
	switch data.ToolName {
	case "apply_patch":
		filePaths = extractApplyPatchFilePaths(data.ToolInput.Command)
	case "Read", "Write", "Edit":
		if data.ToolInput.FilePath != "" {
			filePaths = []string{data.ToolInput.FilePath}
		}
	default:
		return
	}

	for _, filePath := range filePaths {
		if reason := checkFile(filePath, &data); reason != "" {
			fmt.Println(protocol.PreToolUseDeny(reason))
			return
		}
	}
}

// checkFile evaluates a single file path through the 3-tier system.
// Returns the deny reason if blocked, empty string if allowed.
func checkFile(filePath string, data *protocol.HookInput) string {
	// Step 1: Exclusions always pass
	if patterns.IsExcluded(filePath) {
		return ""
	}

	// Step 2: Directory block — always block sensitive directories
	if matched, reason := patterns.MatchesDirectoryBlock(filePath); matched {
		return fmt.Sprintf("BLOCKED: Access to sensitive file denied — %s (%s). Add to .agentignore exceptions if needed.", filePath, reason)
	}

	// Step 3: Always-block — binary/opaque files
	if matched, reason := patterns.MatchesAlwaysBlock(filePath); matched {
		return fmt.Sprintf("BLOCKED: Access to sensitive file denied — %s (%s). Add to .agentignore exceptions if needed.", filePath, reason)
	}

	// Step 4: Content-scan — text configs scanned for actual secrets
	if patterns.MatchesContentScan(filePath) {
		return scanContent(filePath, data)
	}

	// Step 5: No pattern match — allow
	return ""
}

// scanContent scans file content for secrets. Returns the deny reason if secrets found, empty if clean.
func scanContent(filePath string, data *protocol.HookInput) string {
	var content string

	if data.ToolName == "Write" {
		// For Write operations, scan the content being written
		content = data.ToolInput.Content
	} else if data.ToolName == "apply_patch" {
		// Codex sends file edits as an apply_patch command; scan the patch body
		// when the target path is in the content-scan tier.
		content = data.ToolInput.Command
	} else {
		// For Read/Edit, scan existing file on disk
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
		return fmt.Sprintf("BLOCKED: Sensitive content detected in %s (%s). Add to .agentignore exceptions if needed.", filePath, description)
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

func extractApplyPatchFilePaths(command string) []string {
	var paths []string
	seen := map[string]bool{}

	for _, line := range strings.Split(command, "\n") {
		line = strings.TrimSpace(line)
		for _, prefix := range []string{
			"*** Add File: ",
			"*** Update File: ",
			"*** Delete File: ",
		} {
			if strings.HasPrefix(line, prefix) {
				path := strings.TrimSpace(strings.TrimPrefix(line, prefix))
				if path != "" && !seen[path] {
					seen[path] = true
					paths = append(paths, path)
				}
			}
		}
	}

	return paths
}
