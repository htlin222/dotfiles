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
	"strings"
	"time"
	"unicode/utf8"

	"github.com/htlin/claude-tools/pkg/dotenv"
)

const (
	apiURL = "https://api.groq.com/openai/v1/chat/completions"
	// defaultModel follows length instructions well; override with $GROQ_MODEL.
	defaultModel = "llama-3.3-70b-versatile"
	// requestTimeout bounds the whole summarize call so the stop hook
	// never hangs on a slow network.
	requestTimeout = 10 * time.Second
	// maxInputRunes caps how much of the assistant message is sent.
	maxInputRunes = 2000
	// maxSummaryRunes is the hard cap enforced on the returned summary.
	maxSummaryRunes = 50
)

// APIKey returns the Groq API key from $GROQ_API_KEY, or from the
// go-tools .env file. Empty string when unavailable.
func APIKey() string {
	return dotenv.Get("GROQ_API_KEY")
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

// SummarizeZHTW condenses text into a short English summary
// of at most 15 words. Returns an error when no API key is configured
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
				Content: "You are a notification summarizer. Condense the user's message into " +
					"a plain English summary of at most 15 words. " +
					"Output only the summary itself — no quotes, labels, or explanations.",
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
