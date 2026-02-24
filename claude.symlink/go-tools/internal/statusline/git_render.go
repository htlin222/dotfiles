package statusline

import (
	"fmt"
	"strings"
)

func renderBranchLine(status *GitStatus) {
	branchLine := status.BranchLine

	// Remove tracking info for display
	displayLine := branchLine
	if idx := strings.Index(branchLine, " ["); idx != -1 {
		displayLine = branchLine[:idx]
	}

	fmt.Printf("%s%s%s%s", Orange, IconBranch, displayLine, Reset)

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

func renderFileStatus(file GitFileStatus) {
	// Color X (index status)
	xColored := colorStatus(file.IndexStatus)
	// Color Y (worktree status)
	yColored := colorStatus(file.WorktreeStatus)

	// Use white for files in current folder (no ../), gray for parent folders
	pathColor := Gray
	if !strings.HasPrefix(file.Path, "../") {
		pathColor = White
	}

	fmt.Printf("%s%s %s%s%s", xColored, yColored, pathColor, file.Path, Reset)

	// Show line changes if available
	if file.LinesAdded > 0 || file.LinesRemoved > 0 {
		fmt.Print("  ")
		if file.LinesAdded > 0 {
			fmt.Printf("%s+%d%s", Green, file.LinesAdded, Reset)
		}
		if file.LinesRemoved > 0 {
			fmt.Printf("%s-%d%s", Red, file.LinesRemoved, Reset)
		}
	}
	// Show total lines dimly
	if file.TotalLines > 0 {
		fmt.Printf(" %s(%dL)%s", Dim, file.TotalLines, Reset)
	}
	fmt.Println()
}
