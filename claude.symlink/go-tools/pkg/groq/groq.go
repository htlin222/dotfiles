// Package groq provides a minimal Groq chat-completions client used to
// shorten notification text before it is pushed to ntfy.
//
// The API key is read from $GROQ_API_KEY, falling back to a .env file in
// the go-tools source directory (~/.claude/go-tools/.env), which is
// git-ignored so the key never lives in the repo.
package groq

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	"unicode/utf8"
)

const (
	apiURL = "https://api.groq.com/openai/v1/chat/completions"
	// defaultModel is a fast/cheap model; override with $GROQ_MODEL.
	defaultModel = "llama-3.1-8b-instant"
	// requestTimeout bounds the whole summarize call so the stop hook
	// never hangs on a slow network.
	requestTimeout = 10 * time.Second
	// maxInputRunes caps how much of the assistant message is sent.
	maxInputRunes = 2000
	// maxSummaryRunes is the hard cap enforced on the returned summary.
	maxSummaryRunes = 50
)

// envFile returns the path to the git-ignored .env next to the go-tools
// sources (~/.claude/go-tools/.env).
func envFile() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return filepath.Join(home, ".claude", "go-tools", ".env")
}

// APIKey returns the Groq API key from $GROQ_API_KEY, or from the
// go-tools .env file. Empty string when unavailable.
func APIKey() string {
	if k := strings.TrimSpace(os.Getenv("GROQ_API_KEY")); k != "" {
		return k
	}
	data, err := os.ReadFile(envFile())
	if err != nil {
		return ""
	}
	return parseEnvValue(string(data), "GROQ_API_KEY")
}

// parseEnvValue extracts the value for key from dotenv-style content.
// Supports comments, "export " prefixes, and single/double quotes.
func parseEnvValue(content, key string) string {
	for _, line := range strings.Split(content, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		line = strings.TrimPrefix(line, "export ")
		k, v, ok := strings.Cut(line, "=")
		if !ok || strings.TrimSpace(k) != key {
			continue
		}
		v = strings.TrimSpace(v)
		if len(v) >= 2 {
			if (v[0] == '"' && v[len(v)-1] == '"') || (v[0] == '\'' && v[len(v)-1] == '\'') {
				v = v[1 : len(v)-1]
			}
		}
		return v
	}
	return ""
}

func model() string {
	if m := strings.TrimSpace(os.Getenv("GROQ_MODEL")); m != "" {
		return m
	}
	return defaultModel
}

type chatRequest struct {
	Model       string    `json:"model"`
	Messages    []message `json:"messages"`
	Temperature float64   `json:"temperature"`
	MaxTokens   int       `json:"max_tokens"`
}

type message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type chatResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

// SummarizeZHTW condenses text into a Traditional Chinese (zh-TW) summary
// of at most 50 characters. Returns an error when no API key is configured
// or the request fails; callers should fall back to the original text.
func SummarizeZHTW(text string) (string, error) {
	key := APIKey()
	if key == "" {
		return "", fmt.Errorf("groq: no API key")
	}

	if runes := []rune(text); len(runes) > maxInputRunes {
		text = string(runes[:maxInputRunes])
	}

	reqBody, err := json.Marshal(chatRequest{
		Model: model(),
		Messages: []message{
			{
				Role: "system",
				Content: "你是通知摘要器。將使用者訊息濃縮成繁體中文（台灣用語）摘要，" +
					"嚴格限制在 50 個字以內，只輸出摘要本身，不要加引號、標籤或任何解釋。",
			},
			{Role: "user", Content: text},
		},
		Temperature: 0.2,
		MaxTokens:   100,
	})
	if err != nil {
		return "", err
	}

	ctx, cancel := context.WithTimeout(context.Background(), requestTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, apiURL, bytes.NewReader(reqBody))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+key)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("groq: status %d", resp.StatusCode)
	}

	var parsed chatResponse
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return "", err
	}
	if len(parsed.Choices) == 0 {
		return "", fmt.Errorf("groq: empty response")
	}

	summary := strings.TrimSpace(parsed.Choices[0].Message.Content)
	summary = strings.Trim(summary, "\"「」『』")
	if summary == "" {
		return "", fmt.Errorf("groq: blank summary")
	}
	if utf8.RuneCountInString(summary) > maxSummaryRunes {
		summary = string([]rune(summary)[:maxSummaryRunes-1]) + "…"
	}
	return summary, nil
}
