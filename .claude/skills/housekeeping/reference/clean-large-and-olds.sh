#!/usr/bin/env bash
# Find LARGE files that are OLD (created long ago) and COLD (not opened for ages).
#
# Algorithm: "storage rent" — score = size_GB × idle_days (byte-days wasted).
#   A 2GB file untouched for 6 months (360 GB·d) outranks a 10GB file
#   used last week (70 GB·d). Gates: created > MIN_CREATED_DAYS ago AND
#   last access > MIN_IDLE_DAYS ago. Top hits are re-checked against
#   Spotlight's kMDItemLastUsedDate (real "last opened", catches apps that
#   read files without touching atime).
#
# Candidate discovery (fast by default):
#   1. mdfind kMDItemFSSize — instant, but Spotlight skips ~/Library & dot-dirs.
#      If Spotlight indexing is DISABLED (mdutil -s), falls back to per-root
#      find over ALL top-level dirs instead (same coverage, visible progress).
#   2. find over curated gap roots (Library + top-level dot-dirs), one root at
#      a time so slow roots are visible in the progress log
#   3. candidate list cached 24h per (root,min-size); --refresh rebuilds,
#      --full does a complete find tree-walk instead (slow but exhaustive)
#
# Progress: timestamped [+Ns] phase logs on stderr; roots slower than 1s are
# called out individually; --verbose logs every root.
#
# Report-only: never deletes. Feed paths to `rip` yourself (then `rip --decompose`).
set -euo pipefail

ROOT="$HOME"
MIN_MB=100
MIN_CREATED_DAYS=180
MIN_IDLE_DAYS=90
TOP=20
MODE=fast          # fast | full
REFRESH=0
VERBOSE=0
CACHE_TTL_HOURS=24

usage() {
  echo "usage: $(basename "$0") [--root DIR] [--min-size MB] [--min-created DAYS]"
  echo "       [--min-idle DAYS] [--top N] [--full] [--refresh] [--verbose]"
  echo "  --full     exhaustive find tree-walk (slow); default is mdfind + gap roots"
  echo "  --refresh  ignore cached candidate list"
  echo "  --verbose  log every gap root scanned (default: only roots taking >1s)"
  exit 0
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --min-size) MIN_MB="$2"; shift 2 ;;
    --min-created) MIN_CREATED_DAYS="$2"; shift 2 ;;
    --min-idle) MIN_IDLE_DAYS="$2"; shift 2 ;;
    --top) TOP="$2"; shift 2 ;;
    --full) MODE=full; shift ;;
    --refresh) REFRESH=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

NOW=$(date +%s)
SECONDS=0
log() { printf '[%s +%3ss] %s\n' "$(date +%H:%M:%S)" "$SECONDS" "$*" >&2; }
nul_count() { tr -cd '\0' <"$1" | wc -c | tr -d ' '; }

# Spotlight indexing state decides discovery strategy AND cache identity
SPOTLIGHT=0
mdutil -s / 2>/dev/null | grep -q "Indexing enabled" && SPOTLIGHT=1

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/housekeeping"
mkdir -p "$CACHE_DIR"
key=$(printf 'v2|%s|%s|%s|%s' "$ROOT" "$MIN_MB" "$MODE" "$SPOTLIGHT" | shasum | cut -c1-12)
CACHE="$CACHE_DIR/candidates-$key.zlist"   # NUL-delimited paths

# Excluded everywhere: cloud placeholders, Trash, Photos/Mail libraries,
# .git objects, node_modules (reinstallable).
find_large() {  # find_large ROOT... — NUL-delimited large files under given roots
  find "$@" -xdev \( \
        -path "*/Library/CloudStorage" -o \
        -path "*/.Trash" -o \
        -path "*.photoslibrary" -o \
        -path "*/Library/Mail" -o \
        -path "*/.git" -o \
        -path "*/node_modules" \
      \) -prune -o -type f -size +"${MIN_MB}"M -print0 2>/dev/null || true
}

cache_fresh() {
  [[ $REFRESH -eq 0 && -s "$CACHE" ]] || return 1
  local mtime age
  mtime=$(stat -f %m "$CACHE")
  age=$(( NOW - mtime ))
  (( age < CACHE_TTL_HOURS * 3600 ))
}

if cache_fresh; then
  log "cache hit: $(nul_count "$CACHE") candidates from $CACHE (<${CACHE_TTL_HOURS}h; --refresh to rebuild)"
elif [[ "$MODE" == full ]]; then
  log "FULL scan of $ROOT for files >${MIN_MB}MB (slow, exhaustive) ..."
  find_large "$ROOT" >"$CACHE.tmp"
  log "full scan done: $(nul_count "$CACHE.tmp") candidates"
  mv "$CACHE.tmp" "$CACHE"
else
  : >"$CACHE.tmp"
  gaps=()
  if [[ $SPOTLIGHT -eq 1 ]]; then
    log "phase 1/3 mdfind: Spotlight query for files >${MIN_MB}MB under $ROOT"
    mdfind -0 -onlyin "$ROOT" "kMDItemFSSize > $(( MIN_MB * 1024 * 1024 ))" \
      >"$CACHE.tmp" 2>/dev/null || true
    log "phase 1/3 mdfind: $(nul_count "$CACHE.tmp") candidates"
    # Gap roots Spotlight doesn't index: Library + top-level dot-dirs
    [[ -d "$ROOT/Library" ]] && gaps+=("$ROOT/Library")
    for d in "$ROOT"/.[!.]*/; do [[ -d "$d" ]] && gaps+=("${d%/}"); done
  else
    log "phase 1/3 mdfind: SKIPPED — Spotlight indexing is disabled (mdutil -s /)"
    log "  falling back to per-root find over every top-level dir (slower first run, cached after)"
    # loose files sitting directly in ROOT
    find "$ROOT" -maxdepth 1 -type f -size +"${MIN_MB}"M -print0 >>"$CACHE.tmp" 2>/dev/null || true
    for d in "$ROOT"/.[!.]*/ "$ROOT"/*/; do [[ -d "$d" ]] && gaps+=("${d%/}"); done
  fi
  log "phase 2/3 gap-scan: ${#gaps[@]} roots (logging roots slower than 1s)"
  part="$CACHE.part"
  i=0
  for g in "${gaps[@]}"; do
    i=$((i+1))
    t0=$SECONDS
    find_large "$g" >"$part"
    dt=$(( SECONDS - t0 ))
    n=$(nul_count "$part")
    if [[ $VERBOSE -eq 1 || $dt -ge 1 ]]; then
      log "  [$i/${#gaps[@]}] ${dt}s $n hits  $g"
    fi
    cat "$part" >>"$CACHE.tmp"
  done
  rm -f "$part"
  sort -zu <"$CACHE.tmp" >"$CACHE.tmp.sorted"
  mv "$CACHE.tmp.sorted" "$CACHE"
  rm -f "$CACHE.tmp"
  log "phase 2/3 gap-scan done: $(nul_count "$CACHE") unique candidates total"
fi

log "phase 3/3 scoring: gates created>${MIN_CREATED_DAYS}d AND idle>${MIN_IDLE_DAYS}d, rent = GB × idle_days"

# stat -f '%z|%B|%a|%N' → size | birthtime | atime | path
xargs -0 stat -f '%z|%B|%a|%N' <"$CACHE" 2>/dev/null |
  awk -F'|' -v now="$NOW" -v minc="$MIN_CREATED_DAYS" -v mini="$MIN_IDLE_DAYS" '
    {
      size=$1; born=$2; atime=$3
      # path may contain "|" — rebuild it from remaining fields
      path=$4; for (i=5; i<=NF; i++) path = path "|" $i
      created_d = (now-born)/86400
      idle_d    = (now-atime)/86400
      if (created_d < minc || idle_d < mini) next
      gb = size/1073741824
      score = gb * idle_d                       # GB·days of storage rent
      printf "%012.2f|%.2f|%.0f|%.0f|%s\n", score, gb, created_d, idle_d, path
    }' |
  sort -t'|' -rn | head -n "$TOP" | {
    printf '\n%10s  %8s  %8s  %8s  %-12s  %s\n' "GB·days" "size" "created" "idle" "last-opened*" "path"
    printf '%s\n' "-----------------------------------------------------------------------------------"
    while IFS='|' read -r score gb created idle path; do
      # Spotlight check: real "last opened" (atime can lie in both directions)
      if [[ $SPOTLIGHT -eq 1 ]]; then
        lastused=$(mdls -raw -name kMDItemLastUsedDate "$path" 2>/dev/null | cut -d' ' -f1)
        [[ "$lastused" == "(null)" || -z "$lastused" ]] && lastused="never"
      else
        lastused="-"
      fi
      printf '%10.0f  %7.2fG  %6.0fd  %6.0fd  %-12s  %s\n' \
        "$score" "$gb" "$created" "$idle" "$lastused" "$path"
    done
    if [[ $SPOTLIGHT -eq 1 ]]; then
      printf '\n* Spotlight kMDItemLastUsedDate — "never" means never opened via GUI.\n'
    else
      printf '\n* Spotlight indexing disabled — no "last opened" data, idle = atime only.\n'
    fi
    printf 'Report only. Delete with: rip <path> ... && yes | rip --decompose\n'
  } || true   # stat on vanished cache entries / head closing the pipe are not errors

log "done"
