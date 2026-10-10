// Package state provides persistent state management for hooks.
package state

import (
	"encoding/json"
	"os"
	"sync"

	"github.com/htlin/claude-tools/internal/config"
)

// State represents the persistent hook state.
type State struct {
	SessionStart      string `json:"session_start,omitempty"`
	PromptCount       int    `json:"prompt_count,omitempty"`
	LastGitCheck      int    `json:"last_git_check,omitempty"`
	LastPressureCheck int    `json:"last_pressure_check,omitempty"`
	QingPersona       string `json:"qing_persona,omitempty"`
}

var (
	stateMu sync.Mutex
)

// Load loads the persistent state from file.
func Load() (*State, error) {
	stateMu.Lock()
	defer stateMu.Unlock()

	stateFile := config.StateFile()
	data, err := os.ReadFile(stateFile)
	if err != nil {
		if os.IsNotExist(err) {
			return &State{}, nil
		}
		return nil, err
	}

	var state State
	if err := json.Unmarshal(data, &state); err != nil {
		return &State{}, nil
	}

	return &state, nil
}

// Save saves the persistent state to file.
func Save(state *State) error {
	stateMu.Lock()
	defer stateMu.Unlock()

	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	data, err := json.MarshalIndent(state, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(config.StateFile(), data, 0644)
}
