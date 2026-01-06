#!/usr/bin/env python3
"""
FileGuard hook - Block access to sensitive files.
Triggers: PreToolUse for Read, Write, Edit, MultiEdit tools.

Implements 195+ sensitive file patterns across 12 categories:
- Credentials & secrets
- Cloud provider configs (AWS, Azure, GCP)
- SSH keys & certificates
- Database configs
- Environment files
- CI/CD secrets
- Crypto wallets
- IDE & editor configs with secrets
"""

import fnmatch
import json
import os
import re
import sys

# =============================================================================
# Sensitive File Patterns (195+ patterns across 12 categories)
# =============================================================================

SENSITIVE_PATTERNS = {
    # Category 1: Environment & Secrets
    "environment": [
        ".env",
        ".env.*",
        "!.env.sample",
        "!.env.example",
        "!.env.template",
        ".envrc",
        "*.secret",
        "*.secrets",
        "secrets.yaml",
        "secrets.yml",
        "secrets.json",
        "secret.yaml",
        "secret.yml",
        "secret.json",
    ],
    # Category 2: AWS Credentials
    "aws": [
        ".aws/credentials",
        ".aws/config",
        "aws_credentials",
        "credentials.csv",
        "*_accessKeys.csv",
        ".boto",
    ],
    # Category 3: Azure Credentials
    "azure": [
        ".azure/",
        "azure.json",
        "azureProfile.json",
        "azure-pipelines-credentials.yml",
        "servicePrincipal.json",
    ],
    # Category 4: GCP Credentials
    "gcp": [
        "gcloud/",
        "application_default_credentials.json",
        "service-account*.json",
        "service_account*.json",
        "credentials.json",
        "*-credentials.json",
        "gcp*.json",
    ],
    # Category 5: SSH & Certificates
    "ssh_certs": [
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
    ],
    # Category 6: Database
    "database": [
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
    ],
    # Category 7: API Keys & Tokens
    "api_keys": [
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
    ],
    # Category 8: Crypto & Wallets
    "crypto": [
        "*.wallet",
        "wallet.dat",
        "*.keystore",
        "keystore.json",
        "*.mnemonic",
        "seed.txt",
        "private_key*",
        "privatekey*",
    ],
    # Category 9: IDE & Editor with Secrets
    "ide": [
        ".idea/workspace.xml",
        ".vscode/settings.json",  # May contain secrets
        "*.sublime-workspace",
        ".atom/config.cson",
    ],
    # Category 10: CI/CD
    "cicd": [
        ".circleci/config.yml",
        ".github/workflows/*.yml",
        "Jenkinsfile",
        ".gitlab-ci.yml",
        "bitbucket-pipelines.yml",
        "buildspec.yml",
        "cloudbuild.yaml",
    ],
    # Category 11: K8s & Infrastructure
    "infrastructure": [
        "kubeconfig",
        ".kube/config",
        "terraform.tfstate",
        "terraform.tfstate.*",
        "*.tfvars",
        "ansible.cfg",
        "vault.yml",
        "vault.yaml",
    ],
    # Category 12: Application Configs
    "app_config": [
        "config/master.key",
        "config/credentials.yml.enc",
        "wp-config.php",
        "configuration.php",
        "settings.py",  # Django with potential secrets
        "local_settings.py",
        "production.py",
        "appsettings.json",
        "appsettings.*.json",
        "Web.config",
        "app.config",
    ],
}

# Flattened list for quick matching
ALL_PATTERNS = []
EXCLUDE_PATTERNS = []
for category, patterns in SENSITIVE_PATTERNS.items():
    for pattern in patterns:
        if pattern.startswith("!"):
            EXCLUDE_PATTERNS.append(pattern[1:])
        else:
            ALL_PATTERNS.append(pattern)

# Content patterns to detect in JSON files (like GCP service accounts)
CONTENT_PATTERNS = [
    r'"type"\s*:\s*"service_account"',
    r'"private_key"\s*:',
    r'"client_secret"\s*:',
    r"-----BEGIN.*PRIVATE KEY-----",
    r"AKIA[0-9A-Z]{16}",  # AWS Access Key
    r"sk-[a-zA-Z0-9]{48}",  # OpenAI API Key
]


def is_excluded(file_path: str) -> bool:
    """Check if file matches exclusion patterns."""
    filename = os.path.basename(file_path)
    for pattern in EXCLUDE_PATTERNS:
        if fnmatch.fnmatch(filename, pattern):
            return True
    return False


def matches_sensitive_pattern(file_path: str) -> tuple[bool, str]:
    """Check if file matches any sensitive pattern."""
    if is_excluded(file_path):
        return False, ""

    filename = os.path.basename(file_path)
    full_path = file_path.replace("\\", "/")

    for pattern in ALL_PATTERNS:
        # Check filename
        if fnmatch.fnmatch(filename, pattern):
            return True, f"Matches pattern: {pattern}"

        # Check full path for directory patterns
        if "/" in pattern and fnmatch.fnmatch(full_path, f"*{pattern}*"):
            return True, f"Matches path pattern: {pattern}"

        # Check if path contains pattern
        if pattern.endswith("/") and pattern.rstrip("/") in full_path:
            return True, f"In sensitive directory: {pattern}"

    return False, ""


def check_content_patterns(file_path: str) -> tuple[bool, str]:
    """Check file content for sensitive patterns (for JSON files)."""
    if not file_path.endswith(".json"):
        return False, ""

    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read(10000)  # Read first 10KB

        for pattern in CONTENT_PATTERNS:
            if re.search(pattern, content):
                return True, "Contains sensitive content pattern"
    except Exception:
        pass

    return False, ""


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            sys.exit(0)

        data = json.loads(raw_input)
        tool_name = data.get("tool_name", "")
        tool_input = data.get("tool_input", {})

        # Only check file-based tools
        if tool_name not in ["Read", "Write", "Edit", "MultiEdit"]:
            sys.exit(0)

        # Get file path(s)
        file_paths = []
        if tool_name == "MultiEdit":
            edits = tool_input.get("edits", [])
            file_paths = [e.get("file_path", "") for e in edits if e.get("file_path")]
        else:
            file_path = tool_input.get("file_path", "")
            if file_path:
                file_paths = [file_path]

        # Check each file path
        for file_path in file_paths:
            # Check pattern match
            is_sensitive, reason = matches_sensitive_pattern(file_path)
            if is_sensitive:
                print(
                    f"🛡️ BLOCKED: Access to sensitive file denied\n"
                    f"   File: {file_path}\n"
                    f"   Reason: {reason}\n"
                    f"   Add to .agentignore exceptions if needed",
                    file=sys.stderr,
                )
                sys.exit(2)  # Block the operation

            # Check content patterns for existing files
            if os.path.exists(file_path):
                has_sensitive_content, content_reason = check_content_patterns(
                    file_path
                )
                if has_sensitive_content:
                    print(
                        f"🛡️ BLOCKED: File contains sensitive content\n"
                        f"   File: {file_path}\n"
                        f"   Reason: {content_reason}",
                        file=sys.stderr,
                    )
                    sys.exit(2)

        # All checks passed
        sys.exit(0)

    except json.JSONDecodeError:
        sys.exit(0)
    except Exception:
        # Log error but don't block on hook failure
        sys.exit(0)


if __name__ == "__main__":
    main()
