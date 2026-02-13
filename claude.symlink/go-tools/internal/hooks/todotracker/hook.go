// Package todotracker scans edited files for TODO/FIXME/HACK and logs them.
package todotracker

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/protocol"
)

var todoPattern = regexp.MustCompile(`(?i)\b(TODO|FIXME|HACK|XXX|WARN)\b[:\s]?(.{0,80})`)

type todoEntry struct {
	Timestamp string `json:"timestamp"`
	File      string `json:"file"`
	Line      int    `json:"line"`
	Tag       string `json:"tag"`
	Text      string `json:"text"`
}

// Run executes the todo-tracker hook.
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

	// Collect file paths
	var paths []string
	if data.ToolInput.FilePath != "" {
		paths = append(paths, data.ToolInput.FilePath)
	}
	for _, edit := range data.ToolInput.Edits {
		if edit.FilePath != "" {
			paths = append(paths, edit.FilePath)
		}
	}

	var todos []todoEntry
	for _, p := range paths {
		todos = append(todos, scanFile(p)...)
	}

	if len(todos) > 0 {
		logTodos(todos)
	}

	fmt.Println(protocol.ContinueResponse())
}

func scanFile(filePath string) []todoEntry {
	f, err := os.Open(filePath)
	if err != nil {
		return nil
	}
	defer f.Close()

	var todos []todoEntry
	scanner := bufio.NewScanner(f)
	lineNum := 0
	for scanner.Scan() {
		lineNum++
		line := scanner.Text()
		matches := todoPattern.FindStringSubmatch(line)
		if matches == nil {
			continue
		}
		todos = append(todos, todoEntry{
			Timestamp: time.Now().Format(time.RFC3339),
			File:      filePath,
			Line:      lineNum,
			Tag:       strings.ToUpper(matches[1]),
			Text:      strings.TrimSpace(matches[2]),
		})
	}
	return todos
}

func logTodos(todos []todoEntry) {
	_ = config.EnsureLogDir()
	logFile := filepath.Join(config.LogDir, "todos.jsonl")

	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()

	for _, t := range todos {
		data, err := json.Marshal(t)
		if err != nil {
			continue
		}
		f.Write(data)
		f.Write([]byte("\n"))
	}
}
