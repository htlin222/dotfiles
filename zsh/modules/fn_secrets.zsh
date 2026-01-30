# Secrets management via pass
#
# Setup - add your API keys to pass:
#   pass insert api/openai
#   pass insert api/anthropic
#
# Usage:
#   passenv VAR_NAME pass/path     - Load single key on-demand
#   withkeys <command>             - Run command with all API keys loaded
#   API keys auto-load on shell start (GPG cached 24h)

# Load a single secret from pass to environment
passenv() {
  local var_name="$1"
  local pass_path="$2"
  if [[ -z "$var_name" || -z "$pass_path" ]]; then
    echo "Usage: passenv VAR_NAME pass/path" >&2
    return 1
  fi
  export "$var_name"="$(pass show "$pass_path" 2>/dev/null)" || {
    echo "Failed to load $pass_path from pass" >&2
    return 1
  }
}

# Run command with API keys loaded (lazy - only prompts if not cached)
withkeys() {
  export OPENAI_API_KEY="${OPENAI_API_KEY:-$(pass show api/openai 2>/dev/null)}"
  export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$(pass show api/anthropic 2>/dev/null)}"
  "$@"
}

# Auto-export common API keys (uses gpg-agent cache)
export OPENAI_API_KEY="${OPENAI_API_KEY:-$(pass show api/openai 2>/dev/null)}"
export OPENAI_KEY="${OPENAI_KEY:-$(pass show api/openai 2>/dev/null)}"
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$(pass show api/anthropic 2>/dev/null)}"
