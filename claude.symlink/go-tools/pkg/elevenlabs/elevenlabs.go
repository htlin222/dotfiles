// Package elevenlabs provides a minimal ElevenLabs text-to-speech client
// used to speak short notification phrases from hooks.
//
// API: POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}
// with an xi-api-key header (https://elevenlabs.io/docs/eleven-api/quickstart).
//
// The API key is read from $ELEVENLABS_API_KEY, falling back to the
// git-ignored ~/.claude/go-tools/.env file. Synthesized audio is cached
// under ~/.claude/cache/tts keyed by voice+model+text, so repeated
// phrases (e.g. a repo name on every stop) hit the API only once.
package elevenlabs

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/htlin/claude-tools/pkg/dotenv"
)

const (
	apiBase = "https://api.elevenlabs.io/v1/text-to-speech/"
	// defaultVoiceID is "George" from the quickstart; override with
	// $ELEVENLABS_VOICE_ID.
	defaultVoiceID = "JBFqnCBsd6RMkjVDRZzb"
	// defaultModelID is the quickstart model; override with $ELEVENLABS_MODEL.
	defaultModelID = "eleven_multilingual_v2"
	// outputFormat is an MP3 preset playable by afplay.
	outputFormat = "mp3_44100_128"
	// requestTimeout bounds the synth call so hooks never hang on a
	// slow network.
	requestTimeout = 15 * time.Second
	// maxInputRunes caps the spoken text; notifications are short phrases.
	maxInputRunes = 300
)

// APIKey returns the ElevenLabs API key from $ELEVENLABS_API_KEY, or
// from the go-tools .env file. Empty string when unavailable.
func APIKey() string {
	return dotenv.Get("ELEVENLABS_API_KEY")
}

func voiceID() string {
	if v := strings.TrimSpace(os.Getenv("ELEVENLABS_VOICE_ID")); v != "" {
		return v
	}
	return defaultVoiceID
}

func modelID() string {
	if m := strings.TrimSpace(os.Getenv("ELEVENLABS_MODEL")); m != "" {
		return m
	}
	return defaultModelID
}

// cacheDir returns the on-disk MP3 cache directory (~/.claude/cache/tts).
func cacheDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return filepath.Join(home, ".claude", "cache", "tts")
}

// cachePath returns the cache file for text under the current voice and
// model, so changing either produces fresh audio.
func cachePath(text string) string {
	dir := cacheDir()
	if dir == "" {
		return ""
	}
	sum := sha256.Sum256([]byte(voiceID() + "|" + modelID() + "|" + text))
	return filepath.Join(dir, fmt.Sprintf("%x.mp3", sum[:12]))
}

type ttsRequest struct {
	Text    string `json:"text"`
	ModelID string `json:"model_id"`
}

// Synthesize converts text to MP3 audio via the ElevenLabs API.
// Returns an error when no API key is configured or the request fails.
func Synthesize(text string) ([]byte, error) {
	key := APIKey()
	if key == "" {
		return nil, fmt.Errorf("elevenlabs: no API key")
	}

	if runes := []rune(text); len(runes) > maxInputRunes {
		text = string(runes[:maxInputRunes])
	}

	reqBody, err := json.Marshal(ttsRequest{Text: text, ModelID: modelID()})
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), requestTimeout)
	defer cancel()

	url := apiBase + voiceID() + "?output_format=" + outputFormat
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(reqBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("xi-api-key", key)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("elevenlabs: status %d", resp.StatusCode)
	}

	audio, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if len(audio) == 0 {
		return nil, fmt.Errorf("elevenlabs: empty audio")
	}
	return audio, nil
}

// FetchTemp synthesizes text to a throwaway MP3 in the system temp
// directory and returns its path. For dynamic text (e.g. per-turn
// summaries) where caching would never hit and only bloat the cache.
func FetchTemp(text string) (string, error) {
	audio, err := Synthesize(text)
	if err != nil {
		return "", err
	}
	tmp, err := os.CreateTemp("", "claude-tts-*.mp3")
	if err != nil {
		return "", err
	}
	if _, err := tmp.Write(audio); err != nil {
		tmp.Close()
		os.Remove(tmp.Name())
		return "", err
	}
	if err := tmp.Close(); err != nil {
		os.Remove(tmp.Name())
		return "", err
	}
	return tmp.Name(), nil
}

// FetchToCache returns the path to a cached MP3 for text, synthesizing
// and caching it on first use. The write is atomic (temp file + rename)
// so concurrent hooks never play a partial file.
func FetchToCache(text string) (string, error) {
	path := cachePath(text)
	if path == "" {
		return "", fmt.Errorf("elevenlabs: no home directory")
	}
	if info, err := os.Stat(path); err == nil && info.Size() > 0 {
		return path, nil
	}

	audio, err := Synthesize(text)
	if err != nil {
		return "", err
	}

	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return "", err
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".tts-*.mp3")
	if err != nil {
		return "", err
	}
	if _, err := tmp.Write(audio); err != nil {
		tmp.Close()
		os.Remove(tmp.Name())
		return "", err
	}
	if err := tmp.Close(); err != nil {
		os.Remove(tmp.Name())
		return "", err
	}
	if err := os.Rename(tmp.Name(), path); err != nil {
		os.Remove(tmp.Name())
		return "", err
	}
	return path, nil
}
