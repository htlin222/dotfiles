package statusline

import (
	"os/exec"
	"strings"
)

// GitStatus contains git status information.
type GitStatus struct {
	BranchLine  string
	AheadCount  int
	BehindCount int
	Files       []GitFileStatus
	TotalFiles  int
}

// GitFileStatus represents a single file's git status.
type GitFileStatus struct {
	IndexStatus    rune
	WorktreeStatus rune
	Path           string
}

// GetGitStatus returns the current git status for a directory.
func GetGitStatus(dir string) *GitStatus {
	status := &GitStatus{}

	// Get branch line
	cmd := exec.Command("git", "status", "-sb")
	cmd.Dir = dir
	output, err := cmd.Output()
	if err != nil {
		return status
	}

	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	if len(lines) == 0 {
		return status
	}

	// Parse branch line
	status.BranchLine = strings.TrimPrefix(lines[0], "## ")

	// Parse ahead/behind
	if strings.Contains(status.BranchLine, "ahead") {
		// Extract number
		if idx := strings.Index(status.BranchLine, "ahead "); idx != -1 {
			numStr := ""
			for i := idx + 6; i < len(status.BranchLine); i++ {
				if status.BranchLine[i] >= '0' && status.BranchLine[i] <= '9' {
					numStr += string(status.BranchLine[i])
				} else {
					break
				}
			}
			for _, c := range numStr {
				status.AheadCount = status.AheadCount*10 + int(c-'0')
			}
		}
	}
	if strings.Contains(status.BranchLine, "behind") {
		if idx := strings.Index(status.BranchLine, "behind "); idx != -1 {
			numStr := ""
			for i := idx + 7; i < len(status.BranchLine); i++ {
				if status.BranchLine[i] >= '0' && status.BranchLine[i] <= '9' {
					numStr += string(status.BranchLine[i])
				} else {
					break
				}
			}
			for _, c := range numStr {
				status.BehindCount = status.BehindCount*10 + int(c-'0')
			}
		}
	}

	// Parse file statuses (skip the first line which is the branch)
	for i := 1; i < len(lines) && i <= 7; i++ {
		line := lines[i]
		if len(line) < 3 {
			continue
		}
		status.Files = append(status.Files, GitFileStatus{
			IndexStatus:    rune(line[0]),
			WorktreeStatus: rune(line[1]),
			Path:           line[3:],
		})
	}

	status.TotalFiles = len(lines) - 1

	return status
}
