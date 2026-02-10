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
	LinesAdded     int
	LinesRemoved   int
	TotalLines     int
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

	// Get numstat for line changes
	numstat := getNumstat(dir)

	// Merge numstat into file statuses
	for i := range status.Files {
		path := status.Files[i].Path
		// Try exact match first
		if stats, ok := numstat[path]; ok {
			status.Files[i].LinesAdded = stats.added
			status.Files[i].LinesRemoved = stats.removed
			continue
		}
		// Try stripping ../ prefixes (status shows relative to cwd, numstat shows relative to repo root)
		normalizedPath := path
		for strings.HasPrefix(normalizedPath, "../") {
			normalizedPath = normalizedPath[3:]
		}
		if stats, ok := numstat[normalizedPath]; ok {
			status.Files[i].LinesAdded = stats.added
			status.Files[i].LinesRemoved = stats.removed
			continue
		}
		// Try matching by basename (for renamed files or path mismatches)
		baseName := path
		if idx := strings.LastIndex(path, "/"); idx != -1 {
			baseName = path[idx+1:]
		}
		for numPath, stats := range numstat {
			if strings.HasSuffix(numPath, "/"+baseName) || numPath == baseName {
				status.Files[i].LinesAdded = stats.added
				status.Files[i].LinesRemoved = stats.removed
				break
			}
		}
	}

	// Get total line counts for each file
	for i := range status.Files {
		status.Files[i].TotalLines = countFileLines(dir, status.Files[i].Path)
	}

	return status
}

// countFileLines counts total lines in a file, resolving relative paths from dir.
func countFileLines(dir, path string) int {
	// Resolve path: could be relative (../foo) or just filename
	var fullPath string
	if strings.HasPrefix(path, "/") {
		fullPath = path
	} else {
		fullPath = dir + "/" + path
	}

	cmd := exec.Command("wc", "-l", fullPath)
	output, err := cmd.Output()
	if err != nil {
		return 0
	}
	// wc -l output: "  123 /path/to/file"
	s := strings.TrimSpace(string(output))
	n := 0
	for _, c := range s {
		if c >= '0' && c <= '9' {
			n = n*10 + int(c-'0')
		} else {
			break
		}
	}
	return n
}

type lineStats struct {
	added   int
	removed int
}

// getNumstat returns a map of file paths to their line change stats.
func getNumstat(dir string) map[string]lineStats {
	result := make(map[string]lineStats)

	// Get staged changes
	cmd := exec.Command("git", "diff", "--cached", "--numstat")
	cmd.Dir = dir
	output, err := cmd.Output()
	if err == nil {
		parseNumstat(string(output), result)
	}

	// Get unstaged changes (for modified files)
	cmd = exec.Command("git", "diff", "--numstat")
	cmd.Dir = dir
	output, err = cmd.Output()
	if err == nil {
		parseNumstat(string(output), result)
	}

	return result
}

// parseNumstat parses git diff --numstat output and adds to the result map.
func parseNumstat(output string, result map[string]lineStats) {
	lines := strings.Split(strings.TrimSpace(output), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}
		// Format: added<TAB>removed<TAB>filename
		parts := strings.Split(line, "\t")
		if len(parts) < 3 {
			continue
		}
		added := parseNumstatNumber(parts[0])
		removed := parseNumstatNumber(parts[1])
		path := parts[2]

		// Accumulate if file appears in both staged and unstaged
		if existing, ok := result[path]; ok {
			result[path] = lineStats{
				added:   existing.added + added,
				removed: existing.removed + removed,
			}
		} else {
			result[path] = lineStats{added: added, removed: removed}
		}
	}
}

// parseNumstatNumber parses a number from numstat output (handles "-" for binary files).
func parseNumstatNumber(s string) int {
	if s == "-" {
		return 0
	}
	n := 0
	for _, c := range s {
		if c >= '0' && c <= '9' {
			n = n*10 + int(c-'0')
		}
	}
	return n
}
