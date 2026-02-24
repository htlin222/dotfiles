package statusline

import (
	"bufio"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	jokeCache     = "/tmp/claude_dad_joke_cache"
	jokeLock      = "/tmp/claude_dad_joke_lock"
	cacheInterval = 5 * time.Minute
)

// GetDadJoke returns a dad joke, with 5-minute caching.
func GetDadJoke() string {
	now := time.Now()

	// Calculate current 5-minute window
	currentWindow := now.Format("200601021504")[:11] // YYYYMMDDHHM (truncate to 5-min window)
	windowMinute := (now.Minute() / 5) * 5
	currentWindow = now.Format("2006010215") + padInt(windowMinute)

	// Check cache
	if cached := readCache(currentWindow); cached != "" {
		return cached
	}

	// Try to acquire lock
	if !acquireLock() {
		// Lock held, use old cached joke regardless of age
		if cached := readCacheAnyAge(); cached != "" {
			return cached
		}
		return "Keep coding and stay curious!"
	}
	defer releaseLock()

	// Fetch new joke
	joke := fetchJoke()
	if joke != "" {
		writeCache(currentWindow, joke)
	}

	if joke == "" {
		return "Keep coding and stay curious!"
	}
	return joke
}

func readCache(currentWindow string) string {
	f, err := os.Open(jokeCache)
	if err != nil {
		return ""
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	if !scanner.Scan() {
		return ""
	}
	cachedTime := scanner.Text()

	if cachedTime != currentWindow {
		return ""
	}

	var joke strings.Builder
	for scanner.Scan() {
		if joke.Len() > 0 {
			joke.WriteByte('\n')
		}
		joke.WriteString(scanner.Text())
	}
	return joke.String()
}

func readCacheAnyAge() string {
	f, err := os.Open(jokeCache)
	if err != nil {
		return ""
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	// Skip timestamp line
	if !scanner.Scan() {
		return ""
	}

	var joke strings.Builder
	for scanner.Scan() {
		if joke.Len() > 0 {
			joke.WriteByte('\n')
		}
		joke.WriteString(scanner.Text())
	}
	return joke.String()
}

func writeCache(currentWindow, joke string) {
	f, err := os.Create(jokeCache)
	if err != nil {
		return
	}
	defer f.Close()

	f.WriteString(currentWindow + "\n")
	f.WriteString(joke)
}

func acquireLock() bool {
	// Clean up stale lock (older than 60 seconds)
	if info, err := os.Stat(jokeLock); err == nil {
		if time.Since(info.ModTime()) > 60*time.Second {
			os.RemoveAll(jokeLock)
		}
	}

	// Try to create lock directory
	err := os.Mkdir(jokeLock, 0755)
	return err == nil
}

func releaseLock() {
	os.RemoveAll(jokeLock)
}

func fetchJoke() string {
	client := &http.Client{Timeout: 2 * time.Second}
	req, err := http.NewRequest("GET", "https://icanhazdadjoke.com/", nil)
	if err != nil {
		return ""
	}
	req.Header.Set("Accept", "text/plain")

	resp, err := client.Do(req)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return ""
	}

	return strings.TrimSpace(string(body))
}

func padInt(n int) string {
	if n < 10 {
		return "0" + string(rune('0'+n))
	}
	return string(rune('0'+n/10)) + string(rune('0'+n%10))
}

// DetectLanguage detects the project language based on config files.
func DetectLanguage(dir string) string {
	checks := []struct {
		files []string
		icon  string
	}{
		{[]string{"Cargo.toml"}, "⚙"},                                      // Rust
		{[]string{"package.json"}, "⬡"},                                    // JS
		{[]string{"pyproject.toml", "setup.py", "requirements.txt"}, "◎"}, // Python
		{[]string{"go.mod"}, "⟐"},                                          // Go
		{[]string{"init.lua"}, "☽"},                                        // Lua
	}

	for _, check := range checks {
		for _, file := range check.files {
			if _, err := os.Stat(filepath.Join(dir, file)); err == nil {
				return check.icon
			}
		}
	}

	// Check for R project
	entries, err := os.ReadDir(dir)
	if err == nil {
		for _, entry := range entries {
			if strings.HasSuffix(entry.Name(), ".Rproj") {
				return "®" // R
			}
		}
	}
	if _, err := os.Stat(filepath.Join(dir, "DESCRIPTION")); err == nil {
		return "®" // R
	}

	return ""
}
