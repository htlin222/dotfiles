//go:build !darwin

package statusline

import (
	"os/exec"
	"strings"
)

// nativeGetCurrentIM falls back to im-select on non-macOS.
func nativeGetCurrentIM() string {
	imSelect := findIMSelect()
	if imSelect == "" {
		return ""
	}
	output, err := exec.Command(imSelect).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(output))
}

// nativeSetIM falls back to im-select on non-macOS.
func nativeSetIM(sourceID string) bool {
	imSelect := findIMSelect()
	if imSelect == "" {
		return false
	}
	return exec.Command(imSelect, sourceID).Run() == nil
}

// nativeIMAvailable returns true if im-select is found.
func nativeIMAvailable() bool {
	return findIMSelect() != ""
}
