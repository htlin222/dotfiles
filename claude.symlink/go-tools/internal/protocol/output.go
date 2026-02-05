package protocol

import "encoding/json"

// HookOutput is the base output structure for hooks.
type HookOutput struct {
	Continue      bool        `json:"continue,omitempty"`
	Decision      string      `json:"decision,omitempty"`
	Reason        string      `json:"reason,omitempty"`
	SystemMessage string      `json:"systemMessage,omitempty"`
	Specific      *HookSpecificOutput `json:"hookSpecificOutput,omitempty"`
}

// HookSpecificOutput contains hook-specific output data.
type HookSpecificOutput struct {
	HookEventName     string `json:"hookEventName,omitempty"`
	AdditionalContext string `json:"additionalContext,omitempty"`
}

// BlockResponse creates a blocking response with reason.
func BlockResponse(reason string) string {
	output := HookOutput{
		Decision: "block",
		Reason:   reason,
	}
	data, _ := json.Marshal(output)
	return string(data)
}

// ContinueResponse creates a continue response.
func ContinueResponse() string {
	output := HookOutput{
		Continue: true,
	}
	data, _ := json.Marshal(output)
	return string(data)
}

// ContinueWithMessage creates a continue response with system message.
func ContinueWithMessage(message string) string {
	output := HookOutput{
		Continue:      true,
		SystemMessage: message,
	}
	data, _ := json.Marshal(output)
	return string(data)
}

// UserPromptResponse creates a response for UserPromptSubmit hooks.
func UserPromptResponse(additionalContext string) string {
	output := HookOutput{
		Specific: &HookSpecificOutput{
			HookEventName:     "UserPromptSubmit",
			AdditionalContext: additionalContext,
		},
	}
	data, _ := json.Marshal(output)
	return string(data)
}
