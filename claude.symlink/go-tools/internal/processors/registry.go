// Package processors provides file type specific processing.
package processors

import (
	"os/exec"
	"path/filepath"
)

// Processor is the interface for file processors.
type Processor interface {
	// Extensions returns the file extensions this processor handles.
	Extensions() []string
	// Process runs the processor on the given file.
	// Returns (success, output) - success=false means issues were found.
	Process(filePath string) (bool, string)
}

// FileProcessors maps extensions to their processors.
var FileProcessors = map[string]Processor{
	".js":   &BiomeProcessor{},
	".jsx":  &BiomeProcessor{},
	".ts":   &BiomeProcessor{},
	".tsx":  &BiomeProcessor{},
	".json": &BiomeProcessor{},
	".css":  &BiomeProcessor{},
	".html": &PrettierProcessor{},
	".md":   &MarkdownProcessor{},
	".mdx":  &PrettierProcessor{},
	".scss": &PrettierProcessor{},
	".less": &PrettierProcessor{},
	".vue":  &PrettierProcessor{},
	".yaml": &PrettierProcessor{},
	".yml":  &PrettierProcessor{},
	".py":   &RuffProcessor{},
	".pyi":  &RuffProcessor{},
	".bib":  &BibtexProcessor{},
	".r":    &LintrProcessor{},
	".R":    &LintrProcessor{},
	".sh":   &ShellcheckProcessor{},
	".bash": &ShellcheckProcessor{},
}

// GetProcessor returns the appropriate processor for a file.
func GetProcessor(filePath string) Processor {
	ext := filepath.Ext(filePath)
	if processor, ok := FileProcessors[ext]; ok {
		return processor
	}
	return nil
}

// ProcessFile runs the appropriate processor on a file.
func ProcessFile(filePath string) (bool, string) {
	processor := GetProcessor(filePath)
	if processor == nil {
		return true, ""
	}
	return processor.Process(filePath)
}

// commandExists checks if a command exists in PATH.
func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}
