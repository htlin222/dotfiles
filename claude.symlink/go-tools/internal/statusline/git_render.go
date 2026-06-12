package statusline

import (
	"fmt"
	"strings"
)

func renderBranchLine(status *GitStatus, linesAdded, linesRemoved int) {
	branchLine := status.BranchLine

	// Remove tracking info for display
	displayLine := branchLine
	if idx := strings.Index(branchLine, " ["); idx != -1 {
		displayLine = branchLine[:idx]
	}

	fmt.Printf("%s%s%s%s", Orange, IconBranch, displayLine, Reset)

	// Total session line changes, right after the branch name
	fmt.Printf(" %s+%d%s%s-%d%s", Green, linesAdded, Reset, Red, linesRemoved, Reset)

	// Show ahead/behind with dots (spaced)
	if status.AheadCount > 0 && status.BehindCount > 0 {
		fmt.Printf(" %s[ahead %d, behind %d]%s ", Yellow, status.AheadCount, status.BehindCount, Reset)
		fmt.Printf("%s%s%s %s%s%s",
			Green, spacedDots(status.AheadCount), Reset,
			Red, spacedDots(status.BehindCount), Reset)
	} else if status.AheadCount > 0 {
		fmt.Printf(" %s[ahead %d] %s%s", Green, status.AheadCount, spacedDots(status.AheadCount), Reset)
	} else if status.BehindCount > 0 {
		fmt.Printf(" %s[behind %d] %s%s", Red, status.BehindCount, spacedDots(status.BehindCount), Reset)
	}
	fmt.Println()
}

// renderFileStatuses renders all file lines with change columns before
// the file name, each column sized to its widest value.
func renderFileStatuses(files []GitFileStatus) {
	type colSet struct{ added, removed, total string }
	cols := make([]colSet, len(files))
	wAdd, wRem, wTot := 0, 0, 0
	for i, f := range files {
		var c colSet
		if f.LinesAdded > 0 {
			c.added = fmt.Sprintf("+%d", f.LinesAdded)
		}
		if f.LinesRemoved > 0 {
			c.removed = fmt.Sprintf("-%d", f.LinesRemoved)
		}
		if f.TotalLines > 0 {
			c.total = fmt.Sprintf("%dL", f.TotalLines)
		}
		cols[i] = c
		wAdd = max(wAdd, len(c.added))
		wRem = max(wRem, len(c.removed))
		wTot = max(wTot, len(c.total))
	}

	for i, file := range files {
		fmt.Print(ClearLine)
		xColored := colorStatus(file.IndexStatus)
		yColored := colorStatus(file.WorktreeStatus)

		// Use white for files in current folder (no ../), gray for parent folders
		pathColor := Gray
		if !strings.HasPrefix(file.Path, "../") {
			pathColor = White
		}

		fmt.Printf("%s%s", xColored, yColored)
		// Pad plain text to column width — ANSI codes inside %-*s
		// would break the alignment. Skip columns empty for all files.
		if wAdd > 0 {
			fmt.Printf(" %s%-*s%s", Green, wAdd, cols[i].added, Reset)
		}
		if wRem > 0 {
			fmt.Printf(" %s%-*s%s", Red, wRem, cols[i].removed, Reset)
		}
		if wTot > 0 {
			fmt.Printf(" %s%*s%s", Dim, wTot, cols[i].total, Reset)
		}
		fmt.Printf(" %s%s%s\n", pathColor, file.Path, Reset)
	}
}
