// Package patterns provides pattern matching for security and suggestions.
package patterns

import (
	"path/filepath"
	"regexp"
	"strings"
)

// SensitivePatterns contains patterns for sensitive files by category.
var SensitivePatterns = map[string][]string{
	// Category 1: Environment & Secrets
	"environment": {
		".env",
		".env.*",
		".envrc",
		"*.secret",
		"*.secrets",
		"secrets.yaml",
		"secrets.yml",
		"secrets.json",
		"secret.yaml",
		"secret.yml",
		"secret.json",
	},
	// Category 2: AWS Credentials
	"aws": {
		".aws/credentials",
		".aws/config",
		"aws_credentials",
		"credentials.csv",
		"*_accessKeys.csv",
		".boto",
	},
	// Category 3: Azure Credentials
	"azure": {
		".azure/",
		"azure.json",
		"azureProfile.json",
		"azure-pipelines-credentials.yml",
		"servicePrincipal.json",
	},
	// Category 4: GCP Credentials
	"gcp": {
		"gcloud/",
		"application_default_credentials.json",
		"service-account*.json",
		"service_account*.json",
		"credentials.json",
		"*-credentials.json",
		"gcp*.json",
	},
	// Category 5: SSH & Certificates
	"ssh_certs": {
		".ssh/",
		"id_rsa",
		"id_rsa.pub",
		"id_dsa",
		"id_ecdsa",
		"id_ed25519",
		"*.pem",
		"*.key",
		"*.p12",
		"*.pfx",
		"*.crt",
		"*.cer",
		"*.der",
		"known_hosts",
		"authorized_keys",
	},
	// Category 6: Database
	"database": {
		".pgpass",
		".my.cnf",
		".mycnf",
		"*.sqlite",
		"*.sqlite3",
		"*.db",
		"database.yml",
		"database.yaml",
		"mongod.conf",
		"redis.conf",
	},
	// Category 7: API Keys & Tokens
	"api_keys": {
		".npmrc",
		".pypirc",
		".netrc",
		".docker/config.json",
		"docker-compose*.yml",
		".git-credentials",
		".gitcredentials",
		"hub",
		"gh_token",
		"github_token",
		"gitlab_token",
		".travis.yml",
		"*.token",
		"auth.json",
		"tokens.json",
	},
	// Category 8: Crypto & Wallets
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
	// Category 9: IDE & Editor with Secrets
	"ide": {
		".idea/workspace.xml",
		".vscode/settings.json",
		"*.sublime-workspace",
		".atom/config.cson",
	},
	// Category 10: CI/CD
	"cicd": {
		".circleci/config.yml",
		".github/workflows/*.yml",
		"Jenkinsfile",
		".gitlab-ci.yml",
		"bitbucket-pipelines.yml",
		"buildspec.yml",
		"cloudbuild.yaml",
	},
	// Category 11: K8s & Infrastructure
	"infrastructure": {
		"kubeconfig",
		".kube/config",
		"terraform.tfstate",
		"terraform.tfstate.*",
		"*.tfvars",
		"ansible.cfg",
		"vault.yml",
		"vault.yaml",
	},
	// Category 12: Application Configs
	"app_config": {
		"config/master.key",
		"config/credentials.yml.enc",
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
}

// ExcludePatterns are patterns that should be allowed even if they match sensitive patterns.
var ExcludePatterns = []string{
	".env.sample",
	".env.example",
	".env.template",
}

// ContentPatterns are regex patterns to detect sensitive content in files.
var ContentPatterns = []*regexp.Regexp{
	regexp.MustCompile(`"type"\s*:\s*"service_account"`),
	regexp.MustCompile(`"private_key"\s*:`),
	regexp.MustCompile(`"client_secret"\s*:`),
	regexp.MustCompile(`-----BEGIN.*PRIVATE KEY-----`),
	regexp.MustCompile(`AKIA[0-9A-Z]{16}`),                // AWS Access Key
	regexp.MustCompile(`sk-[a-zA-Z0-9]{48}`),              // OpenAI API Key
}

// allPatterns is a flattened list of all sensitive patterns.
var allPatterns []string

func init() {
	for _, patterns := range SensitivePatterns {
		for _, p := range patterns {
			if !strings.HasPrefix(p, "!") {
				allPatterns = append(allPatterns, p)
			}
		}
	}
}

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

// MatchesSensitivePattern checks if a file path matches any sensitive pattern.
// Returns (matches, reason) tuple.
func MatchesSensitivePattern(filePath string) (bool, string) {
	if IsExcluded(filePath) {
		return false, ""
	}

	filename := filepath.Base(filePath)
	fullPath := strings.ReplaceAll(filePath, "\\", "/")

	for _, pattern := range allPatterns {
		// Check filename match
		if matched, _ := filepath.Match(pattern, filename); matched {
			return true, "Matches pattern: " + pattern
		}

		// Check full path for directory patterns
		if strings.Contains(pattern, "/") {
			if matched, _ := filepath.Match("*"+pattern+"*", fullPath); matched {
				return true, "Matches path pattern: " + pattern
			}
		}

		// Check if path contains pattern (for directory patterns ending in /)
		if strings.HasSuffix(pattern, "/") {
			dirName := strings.TrimSuffix(pattern, "/")
			if strings.Contains(fullPath, dirName) {
				return true, "In sensitive directory: " + pattern
			}
		}
	}

	return false, ""
}

// HasSensitiveContent checks file content for sensitive patterns.
func HasSensitiveContent(content string) (bool, string) {
	for _, pattern := range ContentPatterns {
		if pattern.MatchString(content) {
			return true, "Contains sensitive content pattern"
		}
	}
	return false, ""
}
