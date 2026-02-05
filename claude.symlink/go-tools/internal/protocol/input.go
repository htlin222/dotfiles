// Package protocol defines JSON input/output structures for Claude Code hooks.
package protocol

// HookInput is the base input structure for all hooks.
type HookInput struct {
	SessionID      string    `json:"session_id,omitempty"`
	CWD            string    `json:"cwd,omitempty"`
	TranscriptPath string    `json:"transcript_path,omitempty"`
	Prompt         string    `json:"prompt,omitempty"`
	ToolName       string    `json:"tool_name,omitempty"`
	ToolInput      ToolInput `json:"tool_input,omitempty"`
	ToolResult     any       `json:"tool_result,omitempty"`
}

// ToolInput contains tool-specific input parameters.
type ToolInput struct {
	FilePath string      `json:"file_path,omitempty"`
	Command  string      `json:"command,omitempty"`
	Content  string      `json:"content,omitempty"`
	Edits    []EditEntry `json:"edits,omitempty"`
}

// EditEntry represents a single edit in MultiEdit operations.
type EditEntry struct {
	FilePath  string `json:"file_path,omitempty"`
	OldString string `json:"old_string,omitempty"`
	NewString string `json:"new_string,omitempty"`
}

// StatuslineInput contains JSON input from Claude Code for statusline.
type StatuslineInput struct {
	Model          ModelInfo     `json:"model,omitempty"`
	Cost           CostInfo      `json:"cost,omitempty"`
	Vim            VimInfo       `json:"vim,omitempty"`
	ContextWindow  ContextInfo   `json:"context_window,omitempty"`
	Workspace      WorkspaceInfo `json:"workspace,omitempty"`
	TranscriptPath string        `json:"transcript_path,omitempty"`
}

// ModelInfo contains model information.
type ModelInfo struct {
	DisplayName string `json:"display_name,omitempty"`
	Name        string `json:"name,omitempty"`
}

// CostInfo contains cost tracking information.
type CostInfo struct {
	TotalCostUSD      float64 `json:"total_cost_usd,omitempty"`
	TotalLinesAdded   int     `json:"total_lines_added,omitempty"`
	TotalLinesRemoved int     `json:"total_lines_removed,omitempty"`
}

// VimInfo contains vim mode information.
type VimInfo struct {
	Mode string `json:"mode,omitempty"`
}

// ContextInfo contains context window information.
type ContextInfo struct {
	ContextWindowSize  int          `json:"context_window_size,omitempty"`
	TotalInputTokens   int          `json:"total_input_tokens,omitempty"`
	TotalOutputTokens  int          `json:"total_output_tokens,omitempty"`
	CurrentUsage       CurrentUsage `json:"current_usage,omitempty"`
}

// CurrentUsage contains current token usage.
type CurrentUsage struct {
	InputTokens             int `json:"input_tokens,omitempty"`
	CacheCreationInputTokens int `json:"cache_creation_input_tokens,omitempty"`
	CacheReadInputTokens    int `json:"cache_read_input_tokens,omitempty"`
}

// WorkspaceInfo contains workspace information.
type WorkspaceInfo struct {
	CurrentDir string `json:"current_dir,omitempty"`
}

// UsageAPIResponse represents the response from Anthropic's usage API.
type UsageAPIResponse struct {
	FiveHour UsagePeriod `json:"five_hour,omitempty"`
	SevenDay UsagePeriod `json:"seven_day,omitempty"`
}

// UsagePeriod represents usage data for a time period.
type UsagePeriod struct {
	Utilization float64 `json:"utilization,omitempty"`
	ResetsAt    string  `json:"resets_at,omitempty"`
}
