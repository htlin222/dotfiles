package patterns

import (
	"testing"
)

// --- TestMatchesAlwaysBlock ---

func TestMatchesAlwaysBlock_BinaryFiles(t *testing.T) {
	tests := []struct {
		path string
		want bool
	}{
		// SSH keys
		{"id_rsa", true},
		{"/home/user/.ssh/id_rsa", true},
		{"id_ed25519", true},
		// Certificates
		{"server.pem", true},
		{"tls.key", true},
		{"cert.p12", true},
		{"cert.pfx", true},
		{"ca.crt", true},
		{"ca.cer", true},
		{"ca.der", true},
		// Database binary
		{"data.sqlite", true},
		{"app.sqlite3", true},
		{"local.db", true},
		// Crypto
		{"my.wallet", true},
		{"wallet.dat", true},
		{"seed.txt", true},
		{"private_key.hex", true},
		// Credential files
		{"/home/user/.pgpass", true},
		{".my.cnf", true},
		{".npmrc", true},
		{".pypirc", true},
		{".netrc", true},
		{".git-credentials", true},
		{"credentials.csv", true},
		{"gh_token", true},
		// Terraform state
		{"terraform.tfstate", true},
		{"terraform.tfstate.backup", true},
		// Rails
		{"/app/config/master.key", true},
	}

	for _, tt := range tests {
		matched, reason := MatchesAlwaysBlock(tt.path)
		if matched != tt.want {
			t.Errorf("MatchesAlwaysBlock(%q) = %v, want %v (reason: %s)", tt.path, matched, tt.want, reason)
		}
	}
}

func TestMatchesAlwaysBlock_TextConfigsNotBlocked(t *testing.T) {
	// These should NOT be always-blocked (they're content-scan tier)
	notBlocked := []string{
		"docker-compose.yml",
		"docker-compose.prod.yml",
		"database.yml",
		"appsettings.json",
		"settings.py",
		".env",
		".env.production",
		"secrets.yaml",
		"Jenkinsfile",
		".github/workflows/ci.yml",
		"kubeconfig",
		"wp-config.php",
	}

	for _, path := range notBlocked {
		matched, reason := MatchesAlwaysBlock(path)
		if matched {
			t.Errorf("MatchesAlwaysBlock(%q) = true, want false (reason: %s)", path, reason)
		}
	}
}

// --- TestMatchesContentScan ---

func TestMatchesContentScan_TextConfigs(t *testing.T) {
	tests := []struct {
		path string
		want bool
	}{
		// Environment files
		{".env", true},
		{".env.production", true},
		{".envrc", true},
		// Docker
		{"docker-compose.yml", true},
		{"docker-compose.prod.yml", true},
		// Database configs
		{"database.yml", true},
		{"database.yaml", true},
		{"mongod.conf", true},
		{"redis.conf", true},
		// CI/CD
		{"Jenkinsfile", true},
		{".gitlab-ci.yml", true},
		{".travis.yml", true},
		// App configs
		{"appsettings.json", true},
		{"appsettings.Development.json", true},
		{"settings.py", true},
		{"wp-config.php", true},
		// Infrastructure
		{"kubeconfig", true},
		{"prod.tfvars", true},
		{"ansible.cfg", true},
		// Secret configs
		{"secrets.yaml", true},
		{"credentials.json", true},
		{"auth.json", true},
		{"tokens.json", true},
		// IDE
		{".vscode/settings.json", true},
		// Cloud
		{"azure.json", true},
		// Non-matching
		{"README.md", false},
		{"main.go", false},
		{"package.json", false},
		{"index.html", false},
	}

	for _, tt := range tests {
		got := MatchesContentScan(tt.path)
		if got != tt.want {
			t.Errorf("MatchesContentScan(%q) = %v, want %v", tt.path, got, tt.want)
		}
	}
}

// --- TestMatchesDirectoryBlock ---

func TestMatchesDirectoryBlock(t *testing.T) {
	tests := []struct {
		path string
		want bool
	}{
		{"/home/user/.ssh/config", true},
		{"/home/user/.ssh/known_hosts", true},
		{"/home/user/.aws/credentials", true},
		{"/home/user/.aws/config", true},
		{"/home/user/.azure/profile.json", true},
		{"/home/user/gcloud/properties", true},
		// Not in sensitive dirs
		{"/home/user/project/.env", false},
		{"/home/user/code/main.go", false},
		{"docker-compose.yml", false},
	}

	for _, tt := range tests {
		matched, reason := MatchesDirectoryBlock(tt.path)
		if matched != tt.want {
			t.Errorf("MatchesDirectoryBlock(%q) = %v, want %v (reason: %s)", tt.path, matched, tt.want, reason)
		}
	}
}

// --- TestHasSensitiveContent ---

func TestHasSensitiveContent_Detections(t *testing.T) {
	tests := []struct {
		name    string
		content string
		want    bool
		desc    string
	}{
		// GCP service account
		{
			"GCP service account",
			`{"type": "service_account", "project_id": "my-project"}`,
			true, "GCP service account JSON",
		},
		// Private key in JSON
		{
			"private key JSON",
			`{"private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIE..."}`,
			true, "Private key in JSON",
		},
		// Client secret
		{
			"client secret",
			`{"client_secret": "GOCSPX-abc123def456"}`,
			true, "Client secret in JSON",
		},
		// PEM private key
		{
			"PEM key",
			"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAK...",
			true, "PEM private key",
		},
		// AWS access key
		{
			"AWS access key",
			"aws_access_key_id = AKIAIOSFODNN7EXAMPLE",
			true, "AWS access key ID",
		},
		// AWS temporary key
		{
			"AWS temp key",
			"ASIAIOSFODNN7EXAMPLE",
			true, "AWS temporary access key ID",
		},
		// AWS secret
		{
			"AWS secret key",
			"aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
			true, "AWS secret access key",
		},
		// Google API key
		{
			"Google API key",
			"GOOGLE_API_KEY=AIzaSyA1234567890abcdefghijklmnopqrstuv",
			true, "Google API key",
		},
		// GitHub token
		{
			"GitHub PAT",
			"token: ghp_1234567890abcdefghijklmnopqrstuvwxyz",
			true, "GitHub personal access token",
		},
		// GitLab token
		{
			"GitLab PAT",
			"GITLAB_TOKEN=glpat-abcdefghij1234567890",
			true, "GitLab personal access token",
		},
		// Hardcoded password
		{
			"hardcoded password",
			`password = "SuperSecret123!"`,
			true, "Hardcoded password",
		},
		// Database URI
		{
			"postgres URI",
			"DATABASE_URL=postgres://user:pass@host:5432/dbname",
			true, "Database connection URI",
		},
		{
			"mongodb URI",
			"MONGO_URL=mongodb://admin:secret@mongo.example.com:27017/app",
			true, "Database connection URI",
		},
		// YAML secret (generic password regex matches first)
		{
			"YAML password",
			"password: mysecretpassword123",
			true, "Hardcoded password",
		},
		{
			"YAML api_key",
			"api_key: sk_live_abcdef1234567890",
			true, "Secret value in YAML/config",
		},
		// .NET connection string (generic password regex matches first due to Password=secret123)
		{
			".NET connstring",
			`ConnectionString = "Server=myServer;Database=myDB;User=sa;Password=secret123;"`,
			true, "Hardcoded password",
		},
		// WordPress
		{
			"WordPress DB pass",
			`define('DB_PASSWORD', 'mysecretpw');`,
			true, "WordPress DB password",
		},
		// Django
		{
			"Django SECRET_KEY",
			`SECRET_KEY = "django-insecure-abc123def456ghi789"`,
			true, "Django SECRET_KEY",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, desc := HasSensitiveContent(tt.content)
			if got != tt.want {
				t.Errorf("HasSensitiveContent() = %v, want %v", got, tt.want)
			}
			if got && desc != tt.desc {
				t.Errorf("HasSensitiveContent() desc = %q, want %q", desc, tt.desc)
			}
		})
	}
}

func TestHasSensitiveContent_SafeContent(t *testing.T) {
	safeContents := []struct {
		name    string
		content string
	}{
		{"plain docker-compose", `version: "3"
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
`},
		{"CI config", `name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
`},
		{"appsettings with env var", `{
  "ConnectionStrings": {
    "Default": "${DATABASE_URL}"
  },
  "Logging": {
    "LogLevel": "Information"
  }
}`},
		{"YAML with env ref", `database:
  host: localhost
  port: 5432
  password: ${DB_PASSWORD}
`},
		{"YAML with short value", `password: ""`},
		{"YAML with short placeholder", `secret: changeme`},
		{"settings with no secrets", `DEBUG = True
ALLOWED_HOSTS = ["*"]
INSTALLED_APPS = ["django.contrib.admin"]
`},
		{"empty content", ""},
	}

	for _, tt := range safeContents {
		t.Run(tt.name, func(t *testing.T) {
			got, desc := HasSensitiveContent(tt.content)
			if got {
				t.Errorf("HasSensitiveContent() = true for safe content %q (desc: %s)", tt.name, desc)
			}
		})
	}
}

// --- TestIsExcluded ---

func TestIsExcluded(t *testing.T) {
	tests := []struct {
		path string
		want bool
	}{
		{".env.sample", true},
		{".env.example", true},
		{".env.template", true},
		{"/project/.env.example", true},
		{".env", false},
		{".env.production", false},
		{"secrets.yaml", false},
	}

	for _, tt := range tests {
		got := IsExcluded(tt.path)
		if got != tt.want {
			t.Errorf("IsExcluded(%q) = %v, want %v", tt.path, got, tt.want)
		}
	}
}

// --- TestMatchesSensitivePattern (backward compat) ---

func TestMatchesSensitivePattern_BackwardCompat(t *testing.T) {
	// Excluded files pass through
	matched, _ := MatchesSensitivePattern(".env.example")
	if matched {
		t.Error("MatchesSensitivePattern(.env.example) should return false")
	}

	// Always-block files still caught
	matched, _ = MatchesSensitivePattern("id_rsa")
	if !matched {
		t.Error("MatchesSensitivePattern(id_rsa) should return true")
	}

	// Content-scan files still caught (as pattern match)
	matched, _ = MatchesSensitivePattern("docker-compose.yml")
	if !matched {
		t.Error("MatchesSensitivePattern(docker-compose.yml) should return true")
	}

	// Non-sensitive files pass
	matched, _ = MatchesSensitivePattern("main.go")
	if matched {
		t.Error("MatchesSensitivePattern(main.go) should return false")
	}
}
