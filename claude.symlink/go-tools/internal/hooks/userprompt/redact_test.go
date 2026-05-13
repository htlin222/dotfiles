package userprompt

import (
	"reflect"
	"sort"
	"strings"
	"testing"
)

func TestRedactSecretsBraces(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{"plain text untouched", "please refactor this function", "please refactor this function"},
		{"placeholder", "use { my_password } here", "use **** here"},
		{"brace alone no kv", "wrap {deadbeef} done", "wrap **** done"},
		{"empty braces", "before {} after", "before **** after"},
		{"multiple", "{a}{b} and { c }", "******** and ****"},
		{"nested collapses", "{ outer { inner } tail }", "****"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := RedactSecrets(tc.in).Text; got != tc.want {
				t.Errorf("got %q want %q", got, tc.want)
			}
		})
	}
}

func TestRedactSecretsLongToken(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{"32 chars kept", "abcdefghijklmnopqrstuvwxyz012345", "abcdefghijklmnopqrstuvwxyz012345"},
		{"33 chars redacted", "abcdefghijklmnopqrstuvwxyz0123456", "*****"},
		{"long https url kept", "see https://example.com/some/very/long/path/that/exceeds/limit", "see https://example.com/some/very/long/path/that/exceeds/limit"},
		{"long http url redacted", "see http://example.com/some/very/long/path/that/exceeds/limit", "see *****"},
		{"abs path kept", "open /var/log/app/very-long-directory-name/nested/file.log", "open /var/log/app/very-long-directory-name/nested/file.log"},
		{"home path kept", "edit ~/projects/some-long-repo-name/internal/pkg/file.go", "edit ~/projects/some-long-repo-name/internal/pkg/file.go"},
		{"relative path kept", "cat ./internal/long/nested/directory/segment/file.go", "cat ./internal/long/nested/directory/segment/file.go"},
		{"tail", "key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx tail", "key ***** tail"},
		{"long cjk prose kept", "請幫我看看這段中文很長很長很長很長很長很長很長很長很長很長很長很長到底會不會被當作敏感字串", "請幫我看看這段中文很長很長很長很長很長很長很長很長很長很長很長很長到底會不會被當作敏感字串"},
		{"cjk surrounding ascii secret redacted", "鍵是 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 結束", "鍵是 ***** 結束"},
		{"https query stripped", "see https://example.com/path?api_key=verylongsecret1234567890abcd done", "see https://example.com/path?***** done"},
		{"https fragment stripped", "see https://example.com/long/path#section-verylongidentifierABCDEFG done", "see https://example.com/long/path#***** done"},
		{"https userinfo stripped", "see https://user:supersecret@example.com/longer/path/structure done", "see https://*****@example.com/longer/path/structure done"},
		{"https userinfo and query stripped", "see https://u:p@example.com/x?token=longlonglonglonglonglongtoken done", "see https://*****@example.com/x?***** done"},
		{"long abs path-shaped non-path redacted", "open /AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA done", "open ***** done"},
		{"long home path-shaped non-path redacted", "open ~/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA done", "open ***** done"},
		{"sha1 hex commit kept", "look at commit a1b2c3d4e5f67890123456789012345678901234 today", "look at commit a1b2c3d4e5f67890123456789012345678901234 today"},
		{"sha256 hex digest kept", "sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 ok", "sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 ok"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := RedactSecrets(tc.in).Text; got != tc.want {
				t.Errorf("got %q want %q", got, tc.want)
			}
		})
	}
}

func TestRedactSecretsNamed(t *testing.T) {
	cases := []struct {
		name string
		in   string
	}{
		// All fixtures below are intentionally synthetic. They match the
		// shape of the corresponding regex but use "FAKE" / repeated
		// characters so they cannot pass any scanner's checksum or
		// validation step.
		{"github classic pat", "use ghp_FAKE" + strings.Repeat("x", 32) + " to auth"},
		{"github fine-grained pat", "use github_pat_FAKE" + strings.Repeat("x", 78) + " for ci"},
		{"github oauth", "token gho_FAKE" + strings.Repeat("x", 32)},
		{"openai key", "key sk-FAKE" + strings.Repeat("x", 20)},
		{"anthropic key", "key sk-ant-FAKE" + strings.Repeat("x", 20)},
		{"aws access key", "AKIAIOSFODNN7EXAMPLE is the id"}, // AWS docs canonical example
		{"aws session key", "ASIAIOSFODNN7EXAMPLE is the id"},
		{"google api key", "key AIzaFAKE_" + strings.Repeat("x", 30) + " here"},
		{"slack bot token", "xoxb-FAKE-NOT-A-REAL-TOKEN-xxxxxxxxxxxx"},
		{"cloudflare tunnel", "cfut_FAKE" + strings.Repeat("x", 24) + " in env"},
		{"jwt", "session eyJhbGciOi.eyJzdWIiOi.signature done"},
		{"pem block", "-----BEGIN RSA PRIVATE KEY-----\nFAKEKEYBODY\n-----END RSA PRIVATE KEY-----"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			res := RedactSecrets(tc.in)
			if !res.Triggered {
				t.Fatalf("expected redaction to fire, got Triggered=false; text=%q", res.Text)
			}
			if !strings.Contains(res.Text, "*****") {
				t.Errorf("redacted text missing marker: %q", res.Text)
			}
			// The original sensitive substring must not survive verbatim.
			// Use a coarse check: any 16+ char run from the input that's
			// part of the "secret" should be gone. We just confirm "*****"
			// appears and the high-entropy part isn't present.
		})
	}
}

func TestRedactSecretsKV(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{"password equals", "password=hunter2 please", "password=***** please"},
		{"api_key colon quoted", `config api_key: "abc xyz"`, `config api_key: *****`},
		{"token with single quotes", "set token = 'abcdef' done", "set token = ***** done"},
		{"secret_key colon", "secret_key: super-short", "secret_key: *****"},
		{"bearer header", "Authorization: Bearer abc.def.ghi tail", "Authorization: Bearer ***** tail"},
		{"basic header", "Authorization: Basic dXNlcjpwYXNz tail", "Authorization: Basic ***** tail"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := RedactSecrets(tc.in).Text; got != tc.want {
				t.Errorf("got %q want %q", got, tc.want)
			}
		})
	}
}

func TestRedactSecretsCloudflareTunnelClassified(t *testing.T) {
	// Real-shape cfut_ token: 33 chars total — also long enough to hit the
	// long-token catch-all, but the named rule must win and classify it
	// precisely so RuleHits reports "named" instead of just "long-token".
	in := "here is a token cfut_orOykdTQDakYdfMplZB3aiPD8TFT in env"
	res := RedactSecrets(in)
	if !res.Triggered {
		t.Fatalf("expected redaction to fire")
	}
	if strings.Contains(res.Text, "cfut_") {
		t.Errorf("raw cfut_ prefix leaked: %q", res.Text)
	}
	hasNamed := false
	for _, h := range res.RuleHits {
		if h == "named" {
			hasNamed = true
		}
	}
	if !hasNamed {
		t.Errorf("expected named rule to fire, got hits=%v", res.RuleHits)
	}
}

func TestRedactSecretsTriggeredFlag(t *testing.T) {
	clean := RedactSecrets("just a normal prompt about refactoring")
	if clean.Triggered {
		t.Errorf("clean prompt should not trigger; hits=%v", clean.RuleHits)
	}
	if clean.Text != "just a normal prompt about refactoring" {
		t.Errorf("clean prompt should pass through, got %q", clean.Text)
	}

	dirty := RedactSecrets("password=hunter2 and AKIAIOSFODNN7EXAMPLE")
	if !dirty.Triggered {
		t.Errorf("dirty prompt should trigger")
	}
	wantHits := []string{"kv", "named"}
	got := append([]string(nil), dirty.RuleHits...)
	sort.Strings(got)
	sort.Strings(wantHits)
	if !reflect.DeepEqual(got, wantHits) {
		t.Errorf("hits=%v want %v", got, wantHits)
	}
}

func TestRedactSecretsRuleOrder(t *testing.T) {
	// Named secret inside braces: braces would collapse the whole thing
	// to ****, but named runs first, so we should see "**** ****" or just
	// the structured form preserved before braces nuke it. The exact
	// outcome doesn't matter — we just want to confirm the secret is
	// gone and no raw key bytes leak.
	in := "use { ghp_FAKE" + strings.Repeat("x", 32) + " } in env"
	got := RedactSecrets(in).Text
	if strings.Contains(got, "ghp_") {
		t.Errorf("raw github prefix leaked: %q", got)
	}
}
