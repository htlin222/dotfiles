package elevenlabs

import (
	"os"
	"strings"
	"testing"
)

func TestCachePathDeterministic(t *testing.T) {
	a := cachePath("dotfiles")
	b := cachePath("dotfiles")
	if a == "" || a != b {
		t.Fatalf("cachePath not deterministic: %q vs %q", a, b)
	}
	if !strings.HasSuffix(a, ".mp3") {
		t.Fatalf("cachePath missing .mp3 suffix: %q", a)
	}
	if c := cachePath("other-repo"); c == a {
		t.Fatalf("different texts collided: %q", c)
	}
}

func TestCachePathVariesWithVoice(t *testing.T) {
	a := cachePath("dotfiles")
	t.Setenv("ELEVENLABS_VOICE_ID", "some-other-voice")
	if b := cachePath("dotfiles"); b == a {
		t.Fatalf("voice change did not change cache path: %q", b)
	}
}

// Run manually with: ELEVENLABS_LIVE_TEST=1 go test ./pkg/elevenlabs/ -run TestSynthesizeLive -v
func TestSynthesizeLive(t *testing.T) {
	if os.Getenv("ELEVENLABS_LIVE_TEST") == "" {
		t.Skip("set ELEVENLABS_LIVE_TEST=1 to run the live API test")
	}
	if APIKey() == "" {
		t.Skip("no API key configured")
	}
	audio, err := Synthesize("dotfiles")
	if err != nil {
		t.Fatalf("Synthesize failed: %v", err)
	}
	if len(audio) < 1000 {
		t.Fatalf("audio suspiciously small: %d bytes", len(audio))
	}
	t.Logf("audio: %d bytes", len(audio))
}
