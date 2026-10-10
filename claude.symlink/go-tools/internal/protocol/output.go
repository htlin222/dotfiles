package protocol

import "encoding/json"

// Output protocol notes (Claude Code + Codex CLI share this binary):
//   - Exit 0 with no stdout = allow / no-op. Guards print nothing on allow.
//   - PreToolUse blocks use hookSpecificOutput.permissionDecision "deny";
//     the top-level decision:"block" form is deprecated for PreToolUse.
//     Codex >= 0.153 parses the same shape (codex-rs/hooks output_parser.rs).
//   - systemMessage is shown to the user only; additionalContext reaches
//     the model.

// HookOutput is the base output structure for hooks.
type HookOutput struct {
	Continue      bool                `json:"continue,omitempty"`
	SystemMessage string              `json:"systemMessage,omitempty"`
	Specific      *HookSpecificOutput `json:"hookSpecificOutput,omitempty"`
}

// HookSpecificOutput contains hook-specific output data.
type HookSpecificOutput struct {
	HookEventName            string `json:"hookEventName,omitempty"`
	PermissionDecision       string `json:"permissionDecision,omitempty"`
	PermissionDecisionReason string `json:"permissionDecisionReason,omitempty"`
	AdditionalContext        string `json:"additionalContext,omitempty"`
}

func marshal(output HookOutput) string {
	data, _ := json.Marshal(output)
	return string(data)
}

// PreToolUseDeny creates a PreToolUse response that denies the tool call.
// The reason is shown to the model; it must be non-empty (Codex rejects an
// empty deny reason).
func PreToolUseDeny(reason string) string {
	return marshal(HookOutput{
		Specific: &HookSpecificOutput{
			HookEventName:            "PreToolUse",
			PermissionDecision:       "deny",
			PermissionDecisionReason: reason,
		},
	})
}

// PostToolUseContext creates a PostToolUse response whose additionalContext
// is fed to the model alongside the tool result.
func PostToolUseContext(additionalContext string) string {
	return marshal(HookOutput{
		Specific: &HookSpecificOutput{
			HookEventName:     "PostToolUse",
			AdditionalContext: additionalContext,
		},
	})
}

// SystemMessage creates a response carrying a user-only notice.
func SystemMessage(message string) string {
	return marshal(HookOutput{SystemMessage: message})
}

// ContinueResponse creates a continue response.
func ContinueResponse() string {
	return marshal(HookOutput{Continue: true})
}

// ContinueWithMessage creates a continue response with system message.
func ContinueWithMessage(message string) string {
	return marshal(HookOutput{Continue: true, SystemMessage: message})
}

// UserPromptResponse creates a response for UserPromptSubmit hooks.
// additionalContext reaches the model; systemMessage is user-only.
// Returns "" when both are empty (caller should print nothing).
func UserPromptResponse(additionalContext, systemMessage string) string {
	if additionalContext == "" && systemMessage == "" {
		return ""
	}
	output := HookOutput{SystemMessage: systemMessage}
	if additionalContext != "" {
		output.Specific = &HookSpecificOutput{
			HookEventName:     "UserPromptSubmit",
			AdditionalContext: additionalContext,
		}
	}
	return marshal(output)
}
