#!/usr/bin/env bash
# env-dx scanner — developer experience readiness check
# Usage: bash scan.sh [--quick]

set -uo pipefail

QUICK=false
[[ "${1:-}" == "--quick" ]] && QUICK=true

# Helpers
has() { command -v "$1" &>/dev/null; }
ok()      { printf "[OK]      %s\n" "$*"; }
missing() { printf "[MISSING] %s\n" "$*"; }
warn()    { printf "[WARN]    %s\n" "$*"; }
fail()    { printf "[FAIL]    %s\n" "$*"; }

# ─── SYSTEM INFO ─────────────────────────────────────────────
echo "=== SYSTEM INFO ==="
echo "User:     $(whoami 2>/dev/null || echo unknown)"
echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "PWD:      $(pwd)"
echo "Date:     $(date -Iseconds 2>/dev/null || date)"
echo "Uname:    $(uname -srm 2>/dev/null || uname -a)"
echo "Shell:    ${SHELL:-unknown} (running: ${BASH:-unknown})"

if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    echo "Distro:   $(. /etc/os-release && echo "${PRETTY_NAME:-$ID}")"
elif [[ "${OSTYPE:-}" == darwin* ]]; then
    echo "Distro:   macOS $(sw_vers -productVersion 2>/dev/null || echo unknown)"
else
    echo "Distro:   unknown"
fi
echo ""

# ─── CONTAINER DETECTION ─────────────────────────────────────
echo "=== CONTAINER DETECTION ==="

if [[ -f /.dockerenv ]]; then
    ok "Docker container detected (/.dockerenv)"
elif grep -qsE 'docker|containerd' /proc/1/cgroup 2>/dev/null; then
    ok "Docker container detected (cgroup)"
elif [[ -f /run/.containerenv ]]; then
    ok "Podman container detected (/run/.containerenv)"
elif grep -qs 'container=podman' /proc/1/environ 2>/dev/null; then
    ok "Podman container detected (environ)"
elif [[ "${container:-}" == "lxc" ]]; then
    ok "LXC container detected"
elif grep -qs 'container=' /proc/1/environ 2>/dev/null; then
    ok "Container detected (generic)"
else
    echo "Not running in a container (bare metal / VM)"
fi

for rt in docker podman nerdctl; do
    has "$rt" && ok "$rt CLI: $("$rt" --version 2>/dev/null | head -1)"
done
echo ""

# ─── REQUIRED TOOLS ──────────────────────────────────────────
echo "=== REQUIRED TOOLS ==="
for tool in uv pnpm cargo R; do
    if has "$tool"; then
        if [[ "$tool" == "R" ]]; then
            ver=$(R --version 2>/dev/null | head -1 || echo "version unknown")
        else
            ver=$("$tool" --version 2>/dev/null | head -1 || echo "version unknown")
        fi
        ok "$tool: $ver"
    else
        missing "$tool"
    fi
done
echo ""

# ─── UV ADD CHECK ─────────────────────────────────────────────
echo "=== UV ADD CHECK ==="
if has uv; then
    _tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'envdx')
    if (cd "$_tmpdir" && uv init --no-workspace -q 2>/dev/null && uv add --quiet requests 2>/dev/null); then
        ok "uv add works (venv creation + dependency resolution OK)"
    else
        fail "uv add failed — check permissions, network, or uv installation"
    fi
    rm -rf "$_tmpdir"
else
    fail "uv not installed — cannot test uv add"
fi
echo ""

# ─── COMMON DEV TOOLS ────────────────────────────────────────
echo "=== COMMON DEV TOOLS ==="
for tool in git curl wget jq make gcc g++ cmake; do
    if has "$tool"; then
        ver=$("$tool" --version 2>/dev/null | head -1 || echo "installed")
        ok "$tool: $ver"
    else
        missing "$tool"
    fi
done
echo ""

# ─── RUNTIMES ─────────────────────────────────────────────────
echo "=== RUNTIMES ==="
for rt in python3 python node npm bun deno ruby java go rustc; do
    if has "$rt"; then
        case "$rt" in
            java) ver=$(java -version 2>&1 | head -1) ;;
            *)    ver=$("$rt" --version 2>/dev/null | head -1) ;;
        esac
        ok "$rt: $ver"
    fi
done
echo ""

# ─── WRITE PERMISSIONS ───────────────────────────────────────
echo "=== WRITE PERMISSIONS ==="
for dir in /tmp "$HOME" "$PWD"; do
    _test_file="$dir/.envdx_write_test_$$"
    if touch "$_test_file" 2>/dev/null; then
        rm -f "$_test_file"
        ok "Writable: $dir"
    else
        fail "Not writable: $dir"
    fi
done
echo ""

# ─── NETWORK (skip with --quick) ─────────────────────────────
if [[ "$QUICK" == false ]]; then
    echo "=== NETWORK CONNECTIVITY ==="
    if has curl; then
        for endpoint in "https://pypi.org/simple/" "https://registry.npmjs.org/" "https://crates.io/" "https://github.com/"; do
            code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 --max-time 5 "$endpoint" 2>/dev/null || echo "000")
            if [[ "$code" =~ ^[23] ]]; then
                ok "Reachable: $endpoint (HTTP $code)"
            else
                fail "Unreachable: $endpoint (HTTP $code)"
            fi
        done
    else
        warn "curl not available — cannot test network connectivity"
    fi
    echo ""
fi

# ─── DISK SPACE (skip with --quick) ──────────────────────────
if [[ "$QUICK" == false ]]; then
    echo "=== DISK SPACE ==="
    df -h "$PWD" "$HOME" /tmp 2>/dev/null | awk '!seen[$0]++' | head -10
    echo ""
fi

# ─── MEMORY ──────────────────────────────────────────────────
echo "=== MEMORY ==="
if [[ "${OSTYPE:-}" == darwin* ]]; then
    sysctl -n hw.memsize 2>/dev/null | awk '{printf "Total: %.1f GB\n", $1/1073741824}'
elif has free; then
    free -h 2>/dev/null | head -3
elif [[ -f /proc/meminfo ]]; then
    head -3 /proc/meminfo
else
    warn "Cannot determine memory info"
fi
echo ""

# ─── GPU ──────────────────────────────────────────────────────
echo "=== GPU ==="
if has nvidia-smi; then
    ok "NVIDIA GPU detected"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader 2>/dev/null || true
elif [[ -d /proc/driver/nvidia ]]; then
    ok "NVIDIA driver present but nvidia-smi not in PATH"
elif has rocm-smi; then
    ok "AMD ROCm GPU detected"
    rocm-smi --showproductname 2>/dev/null | head -5 || true
elif [[ "${OSTYPE:-}" == darwin* ]]; then
    system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Chipset|VRAM|Metal' | head -5 || echo "macOS GPU (use system_profiler for details)"
else
    echo "No GPU detected"
fi
echo ""

# ─── ENVIRONMENT VARIABLES ───────────────────────────────────
echo "=== ENVIRONMENT ==="
for var in PATH HOME USER SHELL LANG LC_ALL TERM EDITOR VISUAL \
           VIRTUAL_ENV CONDA_DEFAULT_ENV DOCKER_HOST KUBERNETES_SERVICE_HOST \
           SSH_CONNECTION CI GITHUB_ACTIONS; do
    val="${!var:-}"
    if [[ -n "$val" ]]; then
        if [[ "$var" == "PATH" ]]; then
            count=$(echo "$val" | tr ':' '\n' | wc -l | tr -d ' ')
            ok "$var: ($count entries)"
        else
            ok "$var=$val"
        fi
    fi
done
echo ""

echo "=== SCAN COMPLETE ==="
