#!/usr/bin/env bash
# cf-gate — manage Cloudflare Access (Zero Trust) gates headlessly via the API.
# Credentials are read from the sibling ../.env (resolved from this script's
# own location, so it works from any cwd).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

: "${CF_ACCOUNT_ID:=}"
: "${CF_API_TOKEN:=}"
: "${CF_API_KEY:=}"
: "${CF_API_EMAIL:=}"
: "${CF_GATE_EMAILS:=}"
API="https://api.cloudflare.com/client/v4"

die() { echo "cf-gate: $*" >&2; exit 1; }

# Auth: prefer a scoped Bearer token; fall back to the global key + email.
auth_headers() {
  if [[ -n "$CF_API_TOKEN" ]]; then
    printf '%s\n' "-H" "Authorization: Bearer ${CF_API_TOKEN}"
  elif [[ -n "$CF_API_KEY" && -n "$CF_API_EMAIL" ]]; then
    printf '%s\n' "-H" "X-Auth-Key: ${CF_API_KEY}" "-H" "X-Auth-Email: ${CF_API_EMAIL}"
  else
    die "no credentials: set CF_API_TOKEN (preferred) or CF_API_KEY + CF_API_EMAIL in $ENV_FILE"
  fi
}

# cf_api METHOD PATH [JSON_BODY] -> prints response body, fails on success:false
cf_api() {
  local method="$1" path="$2" body="${3:-}"
  [[ -n "$CF_ACCOUNT_ID" ]] || die "Set CF_ACCOUNT_ID in $ENV_FILE (see .env.example)"
  local hdrs; mapfile -t hdrs < <(auth_headers)
  local args=(-sS -X "$method" "${hdrs[@]}" -H "Content-Type: application/json")
  [[ -n "$body" ]] && args+=(--data "$body")
  local resp; resp="$(curl "${args[@]}" "${API}${path}")"
  if [[ "$(jq -r '.success' <<<"$resp")" != "true" ]]; then
    echo "Cloudflare API error (${method} ${path}):" >&2
    jq -r '.errors[]? | "  [\(.code)] \(.message)"' <<<"$resp" >&2
    return 1
  fi
  printf '%s' "$resp"
}

# Build the "include" array (allow rules) from a list of emails.
# A bare "*" means allow any authenticated email_domain match is NOT implied;
# instead "@domain.com" entries become email_domain rules.
build_includes() {
  local list="$1" out="[]" item
  for item in $(tr ',' ' ' <<<"$list"); do
    [[ -z "$item" ]] && continue
    if [[ "$item" == @* ]]; then
      out="$(jq --arg d "${item#@}" '. + [{email_domain:{domain:$d}}]' <<<"$out")"
    else
      out="$(jq --arg e "$item" '. + [{email:{email:$e}}]' <<<"$out")"
    fi
  done
  [[ "$out" == "[]" ]] && die "no allow emails given and CF_GATE_EMAILS is empty"
  printf '%s' "$out"
}

app_id_for() { # hostname -> app id (empty if none)
  cf_api GET "/accounts/${CF_ACCOUNT_ID}/access/apps?per_page=1000" \
    | jq -r --arg d "$1" 'first(.result[] | select(.domain==$d) | .id) // empty'
}

cmd_gate() {
  local host="${1:-}"; shift || true
  [[ -n "$host" ]] || die "usage: cf-gate gate <hostname> [email|@domain ...]"
  local emails="${*:-$CF_GATE_EMAILS}"
  local includes; includes="$(build_includes "$emails")"
  local body; body="$(jq -n \
    --arg name "cf-gate: ${host}" --arg domain "$host" \
    --argjson inc "$includes" \
    '{name:$name, domain:$domain, type:"self_hosted", session_duration:"24h",
      app_launcher_visible:false,
      policies:[{name:"cf-gate allow", decision:"allow", include:$inc}]}')"
  local existing; existing="$(app_id_for "$host")"
  if [[ -n "$existing" ]]; then
    cf_api PUT "/accounts/${CF_ACCOUNT_ID}/access/apps/${existing}" "$body" >/dev/null
    echo "✓ updated gate on ${host} (app ${existing})"
  else
    local id; id="$(cf_api POST "/accounts/${CF_ACCOUNT_ID}/access/apps" "$body" | jq -r '.result.id')"
    echo "✓ gated ${host} (app ${id})"
  fi
  echo "  allow: ${emails}"
}

cmd_ungate() {
  local host="${1:-}"; [[ -n "$host" ]] || die "usage: cf-gate ungate <hostname>"
  local id; id="$(app_id_for "$host")"
  [[ -n "$id" ]] || { echo "no gate found on ${host}"; return 0; }
  cf_api DELETE "/accounts/${CF_ACCOUNT_ID}/access/apps/${id}" >/dev/null
  echo "✓ removed gate on ${host} (app ${id})"
}

cmd_list() {
  cf_api GET "/accounts/${CF_ACCOUNT_ID}/access/apps?per_page=1000" \
    | jq -r '.result[] | "\(.id)\t\(.domain // "-")\t\(.name)"' \
    | column -t -s $'\t'
}

cmd_status() {
  local host="${1:-}"; [[ -n "$host" ]] || die "usage: cf-gate status <hostname>"
  local id; id="$(app_id_for "$host")"
  [[ -n "$id" ]] || { echo "no gate found on ${host}"; return 0; }
  cf_api GET "/accounts/${CF_ACCOUNT_ID}/access/apps/${id}/policies" \
    | jq '{app:"'"$host"'", id:"'"$id"'",
           policies:[.result[] | {name, decision,
             include:[.include[] | (.email.email // .email_domain.domain // "?")]}]}'
}

cmd_whoami() {
  cf_api GET "/accounts/${CF_ACCOUNT_ID}/access/apps?per_page=1" >/dev/null
  echo "✓ credentials valid for account ${CF_ACCOUNT_ID}"
}

# Zone id of the longest-matching Cloudflare zone for a hostname (empty if none).
zone_id_for_host() {
  cf_api GET "/zones?per_page=1000" \
    | jq -r --arg h "$1" '
        [ .result[] | . as $z
          | select(($h == $z.name) or ($h | endswith("." + $z.name))) ]
        | sort_by(.name | length) | last | .id // empty'
}

# Ensure a proxied CNAME host -> <project>.pages.dev exists. Degrades gracefully
# if the token lacks Zone:DNS:Edit (just prints guidance) so the caller's
# already-done work is not lost.
ensure_cname() {
  local host="$1" project="$2" zid existing
  if ! zid="$(zone_id_for_host "$host")" || [[ -z "$zid" ]]; then
    echo "  ! no Cloudflare zone matches ${host} (or token lacks Zone:Read) — create the CNAME manually" >&2
    return 0
  fi
  if ! existing="$(cf_api GET "/zones/${zid}/dns_records?name=${host}" | jq -r '.result | length')"; then
    echo "  ! cannot read DNS (token likely missing Zone:DNS:Edit) — add that scope, then re-run pages-domain" >&2
    return 0
  fi
  if [[ "$existing" != "0" ]]; then echo "  • DNS record for ${host} already exists"; return 0; fi
  if cf_api POST "/zones/${zid}/dns_records" \
      "$(jq -n --arg n "$host" --arg c "${project}.pages.dev" \
         '{type:"CNAME", name:$n, content:$c, proxied:true, comment:"cf-gate"}')" >/dev/null; then
    echo "  ✓ created proxied CNAME ${host} → ${project}.pages.dev"
  else
    echo "  ! CNAME create failed (token likely missing Zone:DNS:Edit) — add that scope or create it manually" >&2
  fi
}

# Attach a custom domain to a Pages project AND create its proxied CNAME, so the
# hostname actually resolves. Needs Pages:Edit; the DNS step needs Zone:DNS:Edit.
cmd_pages_domain() {
  local project="${1:-}" host="${2:-}" have
  [[ -n "$project" && -n "$host" ]] || die "usage: cf-gate pages-domain <project> <hostname>"
  have="$(cf_api GET "/accounts/${CF_ACCOUNT_ID}/pages/projects/${project}/domains" \
          | jq -r --arg h "$host" '[.result[]? | select(.name==$h)] | length')"
  if [[ "$have" == "0" ]]; then
    cf_api POST "/accounts/${CF_ACCOUNT_ID}/pages/projects/${project}/domains" \
      "$(jq -n --arg n "$host" '{name:$n}')" \
      | jq -r '"✓ added \(.result.name) to Pages project '"$project"' (status: \(.result.status))"'
  else
    echo "• ${host} already attached to ${project}"
  fi
  ensure_cname "$host" "$project"
}

usage() {
  cat <<'EOF'
cf-gate — headless Cloudflare Access gates

  cf-gate gate   <hostname> [email|@domain ...]   create/update an allow-email gate
  cf-gate ungate <hostname>                       remove the gate
  cf-gate list                                    list all Access apps
  cf-gate status <hostname>                        show the gate's policies
  cf-gate whoami                                  verify credentials
  cf-gate pages-domain <project> <hostname>       attach a custom domain to a Pages project

Emails default to CF_GATE_EMAILS from .env when omitted.
Use @example.com to allow any address on that domain.
EOF
}

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    gate)         cmd_gate "$@" ;;
    ungate)       cmd_ungate "$@" ;;
    list)         cmd_list "$@" ;;
    status)       cmd_status "$@" ;;
    whoami)       cmd_whoami "$@" ;;
    pages-domain) cmd_pages_domain "$@" ;;
    ""|-h|--help|help) usage ;;
    *) die "unknown command '$cmd' (try: cf-gate help)" ;;
  esac
}

main "$@"
