# Secrets management via pass
#
# Setup - add your API keys to pass:
#   pass insert api/openai
#   pass insert api/anthropic
#
# Usage:
#   passenv VAR_NAME pass/path     - Load single key on-demand (blocking)
#   withkeys <command>             - Run command with openai/anthropic loaded
#   loadkeys                       - Eagerly load all keys now (blocking)
#   secrets-status                 - Show whether bg load finished and which keys are set
#
# Startup behavior:
#   On the first interactive prompt, a background job pre-fetches all keys via
#   `pass show`. The shell stays responsive. On each subsequent prompt, results
#   are picked up and exported. If you need a key for your VERY first command,
#   run `loadkeys` to block until ready.

# ---------- ad-hoc helpers (unchanged API) ----------

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
  loadkeys
  "$@"
}

# ---------- registry of (env_var, pass_path) pairs ----------
# Add new keys here. Each entry: "VAR_NAME=pass/path".
# Aliases (same value under another name) go in _SECRETS_ALIASES.
typeset -ga _SECRETS_KEYS=(
  "OPENAI_API_KEY=api/openai"
  "ANTHROPIC_API_KEY=api/anthropic"
  "TURSO_DATABASE_URL=api/turso/url"
  "TURSO_AUTH_TOKEN=api/turso/token"
)
typeset -gA _SECRETS_ALIASES=(
  [OPENAI_KEY]=OPENAI_API_KEY
)

# ---------- blocking load (explicit) ----------
loadkeys() {
  [[ -n "$_SECRETS_LOADED" ]] && return 0
  local entry var path v alias_var src_var
  for entry in $_SECRETS_KEYS; do
    var="${entry%%=*}"
    path="${entry#*=}"
    # Already set? skip the gpg call
    [[ -n "${(P)var}" ]] && continue
    v=$(pass show "$path" 2>/dev/null) && [[ -n "$v" ]] && export "$var"="$v"
  done
  for alias_var src_var in ${(kv)_SECRETS_ALIASES}; do
    [[ -z "${(P)alias_var}" && -n "${(P)src_var}" ]] && export "$alias_var"="${(P)src_var}"
  done
  _SECRETS_LOADED=1
}

# ---------- non-blocking background load ----------

_SECRETS_STATE_FILE="${TMPDIR:-/tmp}/zsh-secrets-$$"

_secrets_kick_bg() {
  [[ -n "$_SECRETS_LOADED" || -n "$_SECRETS_KICKED" ]] && return
  _SECRETS_KICKED=1
  local out="$_SECRETS_STATE_FILE"
  {
    local entry var path v alias_var src_var
    typeset -A _vals
    for entry in $_SECRETS_KEYS; do
      var="${entry%%=*}"
      path="${entry#*=}"
      v=$(pass show "$path" 2>/dev/null) && [[ -n "$v" ]] && {
        print -r -- "export ${var}=${(q)v}"
        _vals[$var]="$v"
      }
    done
    for alias_var src_var in ${(kv)_SECRETS_ALIASES}; do
      [[ -n "${_vals[$src_var]}" ]] && \
        print -r -- "export ${alias_var}=${(q)_vals[$src_var]}"
    done
    print -r -- "_SECRETS_LOADED=1"
    mv "${out}.tmp" "$out"
  } > "${out}.tmp" 2>/dev/null &!
}

_secrets_check() {
  [[ -n "$_SECRETS_LOADED" ]] && {
    add-zsh-hook -d precmd _secrets_check 2>/dev/null
    return
  }
  [[ -e "$_SECRETS_STATE_FILE" ]] && {
    source "$_SECRETS_STATE_FILE"
    command rm -f "$_SECRETS_STATE_FILE"
    add-zsh-hook -d precmd _secrets_check 2>/dev/null
  }
}

secrets-status() {
  if [[ -n "$_SECRETS_LOADED" ]]; then
    print -r -- "secrets: loaded"
  elif [[ -e "$_SECRETS_STATE_FILE" ]]; then
    print -r -- "secrets: bg complete, waiting for next prompt to source"
  elif [[ -n "$_SECRETS_KICKED" ]]; then
    print -r -- "secrets: bg job in flight (run \`loadkeys\` to block)"
  else
    print -r -- "secrets: not started yet"
  fi
  local entry var
  for entry in $_SECRETS_KEYS; do
    var="${entry%%=*}"
    [[ -n "${(P)var}" ]] && print -r -- "  ${var}: set" || print -r -- "  ${var}: unset"
  done
}

# ---------- wire into interactive shells only ----------
if [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _secrets_kick_bg
  add-zsh-hook precmd _secrets_check
fi
