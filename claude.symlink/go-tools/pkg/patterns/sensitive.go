// Package patterns provides pattern matching for security and suggestions.
package patterns

import (
	"path/filepath"
	"regexp"
	"strings"
)

// --- Tier 1: AlwaysBlock — binary/opaque files that can't be meaningfully scanned ---

// AlwaysBlockPatterns contains files that are always blocked by filename alone.
// These are binary, encrypted, or inherently credential files.
var AlwaysBlockPatterns = map[string][]string{
	// SSH keys (private)
	"ssh_keys": {
		"id_rsa",
		"id_dsa",
		"id_ecdsa",
		"id_ed25519",
	},
	// Certificates & key files
	"certs": {
		"*.pem",
		"*.key",
		"*.p12",
		"*.pfx",
		"*.crt",
		"*.cer",
		"*.der",
	},
	// Database files (binary)
	"database_binary": {
		"*.sqlite",
		"*.sqlite3",
		"*.db",
	},
	// Crypto wallets
	"crypto": {
		"*.wallet",
		"wallet.dat",
		"*.keystore",
		"keystore.json",
		"*.mnemonic",
		"seed.txt",
		"private_key*",
		"privatekey*",
	},
	// Credential files (always contain secrets by definition)
	"credentials": {
		".aws/credentials",
		".pgpass",
		".my.cnf",
		".mycnf",
		".npmrc",
		".pypirc",
		".netrc",
		".git-credentials",
		".gitcredentials",
		".boto",
		"credentials.csv",
		"*_accessKeys.csv",
		"gh_token",
		"github_token",
		"gitlab_token",
	},
	// Terraform state (contains secrets in plaintext)
	"tfstate": {
		"terraform.tfstate",
		"terraform.tfstate.*",
	},
	// Rails encrypted credentials
	"rails": {
		"config/master.key",
		"config/credentials.yml.enc",
	},
}

// --- Tier 2: ContentScan — text config files scanned for secrets before blocking ---

// ContentScanPatterns contains files that should be scanned for content before blocking.
// These are text-based config files that MAY contain secrets but often don't.
var ContentScanPatterns = map[string][]string{
	// Environment files
	"environment": {
		".env",
		".env.*",
		".envrc",
		"*.secret",
		"*.secrets",
	},
	// Secret/credential config files
	"secret_configs": {
		"secrets.yaml",
		"secrets.yml",
		"secrets.json",
		"secret.yaml",
		"secret.yml",
		"secret.json",
		"credentials.json",
		"*-credentials.json",
		"service-account*.json",
		"service_account*.json",
		"auth.json",
		"tokens.json",
		"*.token",
	},
	// Cloud configs
	"cloud": {
		".aws/config",
		"aws_credentials",
		"azure.json",
		"azureProfile.json",
		"azure-pipelines-credentials.yml",
		"servicePrincipal.json",
		"application_default_credentials.json",
		"gcp*.json",
	},
	// Docker
	"docker": {
		".docker/config.json",
		"docker-compose*.yml",
	},
	// Database configs
	"database_config": {
		"database.yml",
		"database.yaml",
		"mongod.conf",
		"redis.conf",
	},
	// CI/CD
	"cicd": {
		".circleci/config.yml",
		".github/workflows/*.yml",
		"Jenkinsfile",
		".gitlab-ci.yml",
		"bitbucket-pipelines.yml",
		"buildspec.yml",
		"cloudbuild.yaml",
		".travis.yml",
	},
	// Infrastructure
	"infrastructure": {
		"kubeconfig",
		".kube/config",
		"*.tfvars",
		"ansible.cfg",
		"vault.yml",
		"vault.yaml",
		"hub",
	},
	// Application configs
	"app_config": {
		"wp-config.php",
		"configuration.php",
		"settings.py",
		"local_settings.py",
		"production.py",
		"appsettings.json",
		"appsettings.*.json",
		"Web.config",
		"app.config",
	},
	// IDE configs
	"ide": {
		".idea/workspace.xml",
		".vscode/settings.json",
		"*.sublime-workspace",
		".atom/config.cson",
	},
	// SSH metadata (not keys themselves)
	"ssh_meta": {
		"id_rsa.pub",
		"known_hosts",
		"authorized_keys",
	},
}

// --- Tier 3: DirectoryBlock — sensitive directories blocked entirely ---

// DirectoryBlockPatterns are directory prefixes that are always blocked.
var DirectoryBlockPatterns = []string{
	".ssh/",
	".aws/",
	".azure/",
	"gcloud/",
}

// --- Exclusions ---

// ExcludePatterns are patterns that should be allowed even if they match sensitive patterns.
var ExcludePatterns = []string{
	".env.sample",
	".env.example",
	".env.template",
}

// --- Content Patterns (regex-based secret detection) ---

// ContentPattern is a regex pattern with a human-readable description.
type ContentPattern struct {
	Pattern     *regexp.Regexp
	Description string
}

// ContentPatterns are regex patterns to detect sensitive content in files.
var ContentPatterns = []ContentPattern{
	// Service account / private key JSON
	{regexp.MustCompile(`"type"\s*:\s*"service_account"`), "GCP service account JSON"},
	{regexp.MustCompile(`"private_key"\s*:`), "Private key in JSON"},
	{regexp.MustCompile(`"client_secret"\s*:`), "Client secret in JSON"},

	// PEM private keys
	{regexp.MustCompile(`-----BEGIN.*PRIVATE KEY-----`), "PEM private key"},

	// AWS
	{regexp.MustCompile(`AKIA[0-9A-Z]{16}`), "AWS access key ID"},
	{regexp.MustCompile(`ASIA[0-9A-Z]{16}`), "AWS temporary access key ID"},
	{regexp.MustCompile(`(?i)aws_secret_access_key\s*[=:]\s*\S{20,}`), "AWS secret access key"},

	// OpenAI
	{regexp.MustCompile(`sk-[a-zA-Z0-9]{48}`), "OpenAI API key"},

	// Google
	{regexp.MustCompile(`AIza[0-9A-Za-z\-_]{35}`), "Google API key"},

	// GitHub / GitLab tokens
	{regexp.MustCompile(`ghp_[0-9a-zA-Z]{36}`), "GitHub personal access token"},
	{regexp.MustCompile(`glpat-[0-9a-zA-Z\-]{20,}`), "GitLab personal access token"},

	// Generic password/secret assignments
	{regexp.MustCompile(`(?i)(password|passwd)\s*[=:]\s*["']?[^\s"'$\{]{8,}`), "Hardcoded password"},

	// Database connection URIs
	{regexp.MustCompile(`(?i)(postgres|mysql|mongodb|redis)://[^\s]{10,}`), "Database connection URI"},

	// YAML secrets (password/secret/token/api_key with literal values, min 12 to skip placeholders)
	{regexp.MustCompile(`(?i)(password|secret|token|api_key):\s*["']?[^\s"'#$\{]{12,}`), "Secret value in YAML/config"},

	// .NET connection strings
	{regexp.MustCompile(`(?i)ConnectionString\s*[=:]\s*["'][^"']{15,}`), ".NET connection string"},

	// WordPress
	{regexp.MustCompile(`(?i)define\s*\(\s*['"]DB_PASSWORD`), "WordPress DB password"},

	// Django
	{regexp.MustCompile(`(?i)SECRET_KEY\s*=\s*["']`), "Django SECRET_KEY"},
}

// --- Flattened pattern caches ---

var alwaysBlockFlat []string
var contentScanFlat []string

func init() {
	for _, patterns := range AlwaysBlockPatterns {
		alwaysBlockFlat = append(alwaysBlockFlat, patterns...)
	}
	for _, patterns := range ContentScanPatterns {
		contentScanFlat = append(contentScanFlat, patterns...)
	}
}

// --- Public API ---

// IsExcluded checks if a file matches exclusion patterns.
func IsExcluded(filePath string) bool {
	filename := filepath.Base(filePath)
	for _, pattern := range ExcludePatterns {
		if matched, _ := filepath.Match(pattern, filename); matched {
			return true
		}
	}
	return false
}

// MatchesDirectoryBlock checks if a file is in a sensitive directory.
// Returns (matches, reason).
func MatchesDirectoryBlock(filePath string) (bool, string) {
	fullPath := strings.ReplaceAll(filePath, "\\", "/")
	for _, dir := range DirectoryBlockPatterns {
		dirName := strings.TrimSuffix(dir, "/")
		if strings.Contains(fullPath, "/"+dirName+"/") || strings.HasPrefix(fullPath, dirName+"/") {
			return true, "In sensitive directory: " + dir
		}
	}
	return false, ""
}

// MatchesAlwaysBlock checks if a file matches always-block patterns (binary/opaque).
// Returns (matches, reason).
func MatchesAlwaysBlock(filePath string) (bool, string) {
	filename := filepath.Base(filePath)
	fullPath := strings.ReplaceAll(filePath, "\\", "/")

	for _, pattern := range alwaysBlockFlat {
		// Check filename match
		if matched, _ := filepath.Match(pattern, filename); matched {
			return true, "Always-block pattern: " + pattern
		}
		// Check full path for patterns with /
		if strings.Contains(pattern, "/") {
			if matched, _ := filepath.Match("*"+pattern, fullPath); matched {
				return true, "Always-block path pattern: " + pattern
			}
			// Also try suffix match
			if strings.HasSuffix(fullPath, "/"+pattern) || strings.HasSuffix(fullPath, pattern) {
				return true, "Always-block path pattern: " + pattern
			}
		}
	}
	return false, ""
}

// MatchesContentScan checks if a file matches content-scan patterns.
// If true, the file should be scanned for secrets before deciding to block.
func MatchesContentScan(filePath string) bool {
	filename := filepath.Base(filePath)
	fullPath := strings.ReplaceAll(filePath, "\\", "/")

	for _, pattern := range contentScanFlat {
		// Check filename match
		if matched, _ := filepath.Match(pattern, filename); matched {
			return true
		}
		// Check full path for patterns with /
		if strings.Contains(pattern, "/") {
			if matched, _ := filepath.Match("*"+pattern, fullPath); matched {
				return true
			}
			if strings.HasSuffix(fullPath, "/"+pattern) || strings.HasSuffix(fullPath, pattern) {
				return true
			}
		}
	}
	return false
}

// HasSensitiveContent checks file content for sensitive patterns.
// Returns (found, description) where description identifies the type of secret found.
func HasSensitiveContent(content string) (bool, string) {
	for _, cp := range ContentPatterns {
		if cp.Pattern.MatchString(content) {
			return true, cp.Description
		}
	}
	return false, ""
}

// --- Backward compatibility ---

// MatchesSensitivePattern checks if a file path matches any sensitive pattern.
// Deprecated: Use MatchesAlwaysBlock, MatchesDirectoryBlock, MatchesContentScan instead.
func MatchesSensitivePattern(filePath string) (bool, string) {
	if IsExcluded(filePath) {
		return false, ""
	}
	if matched, reason := MatchesDirectoryBlock(filePath); matched {
		return true, reason
	}
	if matched, reason := MatchesAlwaysBlock(filePath); matched {
		return true, reason
	}
	if MatchesContentScan(filePath) {
		return true, "Matches content-scan pattern"
	}
	return false, ""
}
