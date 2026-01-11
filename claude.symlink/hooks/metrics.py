#!/usr/bin/env python3
"""
Hook Metrics & Profiling Module

Features:
1. Execution time tracking for hooks
2. Event logging for observability dashboard
3. Token usage estimation
4. Performance warnings for slow hooks
"""

import functools
import json
import os
import sys
import time
from datetime import datetime
from typing import Any, Callable

from ansi import C, Icons, header, separator

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
METRICS_LOG_FILE = os.path.join(LOG_DIR, "hook_metrics.jsonl")
EVENTS_LOG_FILE = os.path.join(LOG_DIR, "hook_events.jsonl")

# Performance thresholds
SLOW_HOOK_THRESHOLD_MS = 500  # Warn if hook takes longer than this
VERY_SLOW_HOOK_THRESHOLD_MS = 2000  # Critical warning

# Token estimation (approximate)
CHARS_PER_TOKEN = 4  # Rough estimate for English text
MAX_USER_PROMPT_CONTEXT_CHARS = 10000  # ~2500 tokens


# =============================================================================
# Token Estimation
# =============================================================================


def estimate_tokens(text: str) -> int:
    """Estimate token count from text (rough approximation)."""
    if not text:
        return 0
    # Simple heuristic: ~4 chars per token for English
    # Adjust for CJK characters (count as ~1.5 tokens each)
    cjk_count = sum(1 for c in text if "\u4e00" <= c <= "\u9fff")
    ascii_count = len(text) - cjk_count
    return int(ascii_count / CHARS_PER_TOKEN + cjk_count * 1.5)


def check_context_size(context: str, hook_name: str) -> dict | None:
    """Check if context injection is too large. Returns warning if needed."""
    if not context:
        return None

    char_count = len(context)
    token_estimate = estimate_tokens(context)

    if char_count > MAX_USER_PROMPT_CONTEXT_CHARS:
        return {
            "warning": "context_too_large",
            "hook": hook_name,
            "chars": char_count,
            "tokens_estimate": token_estimate,
            "limit": MAX_USER_PROMPT_CONTEXT_CHARS,
            "message": f"⚠️ {hook_name}: Context injection too large ({char_count} chars, ~{token_estimate} tokens). Limit: {MAX_USER_PROMPT_CONTEXT_CHARS} chars",
        }

    if char_count > MAX_USER_PROMPT_CONTEXT_CHARS * 0.8:
        return {
            "warning": "context_approaching_limit",
            "hook": hook_name,
            "chars": char_count,
            "tokens_estimate": token_estimate,
            "limit": MAX_USER_PROMPT_CONTEXT_CHARS,
            "message": f"⚡ {hook_name}: Context injection approaching limit ({char_count}/{MAX_USER_PROMPT_CONTEXT_CHARS} chars)",
        }

    return None


# =============================================================================
# Execution Time Tracking
# =============================================================================


def log_hook_metrics(
    hook_name: str,
    event_type: str,
    execution_time_ms: float,
    input_size: int = 0,
    output_size: int = 0,
    success: bool = True,
    error: str | None = None,
    extra: dict | None = None,
):
    """Log hook execution metrics."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "hook": hook_name,
        "event_type": event_type,
        "execution_time_ms": round(execution_time_ms, 2),
        "input_size": input_size,
        "output_size": output_size,
        "success": success,
        "error": error,
    }

    if extra:
        entry.update(extra)

    # Add performance warning if slow
    if execution_time_ms > VERY_SLOW_HOOK_THRESHOLD_MS:
        entry["performance"] = "critical"
    elif execution_time_ms > SLOW_HOOK_THRESHOLD_MS:
        entry["performance"] = "slow"
    else:
        entry["performance"] = "ok"

    try:
        with open(METRICS_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass

    return entry


def profile_hook(hook_name: str, event_type: str):
    """Decorator to profile hook execution time."""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.perf_counter()
            success = True
            error = None
            result = None

            try:
                result = func(*args, **kwargs)
            except Exception as e:
                success = False
                error = str(e)
                raise
            finally:
                end_time = time.perf_counter()
                execution_time_ms = (end_time - start_time) * 1000

                log_hook_metrics(
                    hook_name=hook_name,
                    event_type=event_type,
                    execution_time_ms=execution_time_ms,
                    success=success,
                    error=error,
                )

            return result

        return wrapper

    return decorator


# =============================================================================
# Event Logging (for Dashboard)
# =============================================================================


def log_hook_event(
    event_type: str,
    hook_name: str,
    session_id: str = "",
    cwd: str = "",
    tool_name: str | None = None,
    tool_input: dict | None = None,
    tool_result: Any = None,
    decision: str | None = None,
    metadata: dict | None = None,
):
    """Log hook event for observability dashboard."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "event_type": event_type,
        "hook": hook_name,
        "session_id": session_id,
        "project": os.path.basename(cwd) if cwd else "",
        "cwd": cwd,
    }

    if tool_name:
        entry["tool_name"] = tool_name

    if tool_input:
        # Truncate large inputs
        entry["tool_input"] = {
            k: (v[:200] + "..." if isinstance(v, str) and len(v) > 200 else v)
            for k, v in tool_input.items()
        }

    if tool_result is not None:
        if isinstance(tool_result, dict):
            entry["tool_result_keys"] = list(tool_result.keys())
        elif isinstance(tool_result, str):
            entry["tool_result_preview"] = tool_result[:100]

    if decision:
        entry["decision"] = decision

    if metadata:
        entry["metadata"] = metadata

    try:
        with open(EVENTS_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass

    return entry


# =============================================================================
# Performance Analysis
# =============================================================================


def get_hook_stats(hours: int = 24) -> dict:
    """Get aggregated hook performance statistics."""
    from datetime import timedelta

    cutoff = datetime.now() - timedelta(hours=hours)
    stats = {}

    if not os.path.exists(METRICS_LOG_FILE):
        return stats

    try:
        with open(METRICS_LOG_FILE, encoding="utf-8") as f:
            for line in f:
                try:
                    entry = json.loads(line.strip())
                    timestamp = datetime.fromisoformat(entry.get("timestamp", ""))
                    if timestamp < cutoff:
                        continue

                    hook = entry.get("hook", "unknown")
                    if hook not in stats:
                        stats[hook] = {
                            "count": 0,
                            "total_time_ms": 0,
                            "max_time_ms": 0,
                            "slow_count": 0,
                            "error_count": 0,
                        }

                    stats[hook]["count"] += 1
                    exec_time = entry.get("execution_time_ms", 0)
                    stats[hook]["total_time_ms"] += exec_time
                    stats[hook]["max_time_ms"] = max(
                        stats[hook]["max_time_ms"], exec_time
                    )

                    if entry.get("performance") in ("slow", "critical"):
                        stats[hook]["slow_count"] += 1

                    if not entry.get("success", True):
                        stats[hook]["error_count"] += 1

                except (json.JSONDecodeError, ValueError):
                    continue

        # Calculate averages
        for hook in stats:
            if stats[hook]["count"] > 0:
                stats[hook]["avg_time_ms"] = round(
                    stats[hook]["total_time_ms"] / stats[hook]["count"], 2
                )

    except Exception:
        pass

    return stats


def print_performance_report(hours: int = 24):
    """Print a performance report to stderr."""
    stats = get_hook_stats(hours)

    if not stats:
        print(f"{C.DIM}{Icons.INFO} No hook metrics found.{C.RESET}", file=sys.stderr)
        return

    print(
        f"\n{header(f'Hook Performance Report (last {hours}h)', Icons.CLOCK)}\n",
        file=sys.stderr,
    )
    print(
        f"{C.BOLD}{'Hook':<25} {'Count':>8} {'Avg(ms)':>10} {'Max(ms)':>10} {'Slow':>6}{C.RESET}",
        file=sys.stderr,
    )
    print(separator("─", 65), file=sys.stderr)

    for hook, data in sorted(
        stats.items(), key=lambda x: x[1]["avg_time_ms"], reverse=True
    ):
        if data["slow_count"] > 0:
            status = f"{C.BRIGHT_RED}{Icons.CROSS}{C.RESET}"
        else:
            status = f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}"
        avg_ms = data.get("avg_time_ms", 0)
        avg_color = (
            C.BRIGHT_RED
            if avg_ms > 500
            else C.BRIGHT_YELLOW
            if avg_ms > 200
            else C.BRIGHT_GREEN
        )
        print(
            f"{status} {C.BRIGHT_CYAN}{hook:<23}{C.RESET} "
            f"{data['count']:>8} "
            f"{avg_color}{avg_ms:>10.1f}{C.RESET} "
            f"{data['max_time_ms']:>10.1f} "
            f"{C.BRIGHT_YELLOW if data['slow_count'] > 0 else C.DIM}{data['slow_count']:>6}{C.RESET}",
            file=sys.stderr,
        )

    print(file=sys.stderr)


# =============================================================================
# CLI Interface
# =============================================================================


def main():
    """CLI for viewing hook metrics."""
    import argparse

    parser = argparse.ArgumentParser(description="Hook Metrics CLI")
    parser.add_argument(
        "command",
        choices=["stats", "events", "clear"],
        help="Command to run",
    )
    parser.add_argument(
        "--hours",
        type=int,
        default=24,
        help="Time range in hours (default: 24)",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Number of events to show (default: 20)",
    )

    args = parser.parse_args()

    if args.command == "stats":
        print_performance_report(args.hours)

    elif args.command == "events":
        if os.path.exists(EVENTS_LOG_FILE):
            with open(EVENTS_LOG_FILE, encoding="utf-8") as f:
                lines = f.readlines()[-args.limit :]
            print(
                f"\n{header(f'Recent Hook Events (last {args.limit})', Icons.COMMENT)}\n"
            )
            for line in lines:
                try:
                    entry = json.loads(line.strip())
                    ts = entry.get("timestamp", "")[:19]
                    event = entry.get("event_type", "")
                    hook = entry.get("hook", "")
                    tool = entry.get("tool_name", "")
                    print(
                        f"  {C.DIM}{ts}{C.RESET} │ "
                        f"{C.BRIGHT_CYAN}{event:<18}{C.RESET} │ "
                        f"{C.BRIGHT_YELLOW}{hook:<20}{C.RESET} │ "
                        f"{C.BRIGHT_MAGENTA}{tool}{C.RESET}"
                    )
                except json.JSONDecodeError:
                    continue
        else:
            print(f"{C.DIM}{Icons.INFO} No events found.{C.RESET}")

    elif args.command == "clear":
        for f in [METRICS_LOG_FILE, EVENTS_LOG_FILE]:
            if os.path.exists(f):
                os.remove(f)
                print(f"Cleared {f}")


if __name__ == "__main__":
    main()
