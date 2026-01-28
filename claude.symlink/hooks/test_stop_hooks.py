#!/usr/bin/env python3
"""
Unit tests for stop hooks - validates JSON output for Claude Code compatibility.

Run: pytest hooks/test_stop_hooks.py -v
"""

import json
import subprocess
import sys
from pathlib import Path

import pytest

HOOKS_DIR = Path(__file__).parent
STOP_HOOK = HOOKS_DIR / "stop.py"
SUBAGENT_STOP_HOOK = HOOKS_DIR / "subagent_stop.py"


def run_hook(hook_path: Path, stdin_data: str = "") -> tuple[str, str, int]:
    """Run a hook script and return (stdout, stderr, returncode)."""
    result = subprocess.run(
        [sys.executable, str(hook_path)],
        input=stdin_data,
        capture_output=True,
        text=True,
        timeout=30,
    )
    return result.stdout, result.stderr, result.returncode


def validate_hook_output(stdout: str) -> dict:
    """Validate that hook output is valid JSON with expected structure."""
    # Find the last line that looks like JSON (hooks may print other stuff to stdout)
    lines = stdout.strip().split("\n")
    json_line = None
    for line in reversed(lines):
        line = line.strip()
        if line.startswith("{") and line.endswith("}"):
            json_line = line
            break

    assert json_line is not None, f"No JSON found in output: {stdout!r}"

    try:
        data = json.loads(json_line)
    except json.JSONDecodeError as e:
        pytest.fail(f"Invalid JSON in output: {json_line!r}, error: {e}")

    # Claude Code expects "continue" key
    assert "continue" in data, f"Missing 'continue' key in output: {data}"
    assert isinstance(data["continue"], bool), (
        f"'continue' must be boolean, got: {type(data['continue'])}"
    )

    return data


class TestStopHook:
    """Tests for stop.py hook."""

    def test_empty_input(self):
        """Hook should output valid JSON even with empty input."""
        stdout, stderr, returncode = run_hook(STOP_HOOK, "")
        assert returncode == 0, f"Hook failed with returncode {returncode}"
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_whitespace_input(self):
        """Hook should handle whitespace-only input."""
        stdout, stderr, returncode = run_hook(STOP_HOOK, "   \n\t  ")
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_invalid_json_input(self):
        """Hook should handle invalid JSON gracefully."""
        stdout, stderr, returncode = run_hook(STOP_HOOK, "not valid json {{{")
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_valid_json_input(self):
        """Hook should process valid JSON input."""
        input_data = json.dumps(
            {
                "cwd": "/tmp/test",
                "session_id": "test-session-123",
                "transcript_path": "",
            }
        )
        stdout, stderr, returncode = run_hook(STOP_HOOK, input_data)
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_missing_fields(self):
        """Hook should handle missing optional fields."""
        input_data = json.dumps({})
        stdout, stderr, returncode = run_hook(STOP_HOOK, input_data)
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True


class TestSubagentStopHook:
    """Tests for subagent_stop.py hook."""

    def test_empty_input(self):
        """Hook should output valid JSON even with empty input."""
        stdout, stderr, returncode = run_hook(SUBAGENT_STOP_HOOK, "")
        assert returncode == 0, f"Hook failed with returncode {returncode}"
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_whitespace_input(self):
        """Hook should handle whitespace-only input."""
        stdout, stderr, returncode = run_hook(SUBAGENT_STOP_HOOK, "   \n\t  ")
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_invalid_json_input(self):
        """Hook should handle invalid JSON gracefully."""
        stdout, stderr, returncode = run_hook(SUBAGENT_STOP_HOOK, "not valid json")
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_valid_json_input(self):
        """Hook should process valid JSON input."""
        input_data = json.dumps(
            {
                "cwd": "/tmp/test",
                "session_id": "subagent-test-456",
            }
        )
        stdout, stderr, returncode = run_hook(SUBAGENT_STOP_HOOK, input_data)
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True

    def test_missing_fields(self):
        """Hook should handle missing optional fields."""
        input_data = json.dumps({})
        stdout, stderr, returncode = run_hook(SUBAGENT_STOP_HOOK, input_data)
        assert returncode == 0
        data = validate_hook_output(stdout)
        assert data["continue"] is True


class TestJsonOutputFormat:
    """Tests for strict JSON output compliance."""

    @pytest.mark.parametrize("hook_path", [STOP_HOOK, SUBAGENT_STOP_HOOK])
    def test_output_is_single_json_line(self, hook_path):
        """Final output line should be valid JSON."""
        input_data = json.dumps({"cwd": "/tmp", "session_id": "test"})
        stdout, stderr, returncode = run_hook(hook_path, input_data)

        # Get last non-empty line
        lines = [line for line in stdout.strip().split("\n") if line.strip()]
        assert len(lines) >= 1, "Hook produced no output"

        last_line = lines[-1].strip()
        try:
            data = json.loads(last_line)
            assert "continue" in data
        except json.JSONDecodeError:
            pytest.fail(f"Last line is not valid JSON: {last_line!r}")

    @pytest.mark.parametrize("hook_path", [STOP_HOOK, SUBAGENT_STOP_HOOK])
    def test_no_trailing_content_after_json(self, hook_path):
        """Ensure no garbage after JSON output."""
        input_data = json.dumps({"cwd": "/tmp", "session_id": "test"})
        stdout, stderr, returncode = run_hook(hook_path, input_data)

        lines = stdout.strip().split("\n")
        last_line = lines[-1].strip()

        # Should be parseable as complete JSON
        data = json.loads(last_line)
        # Re-serialize should match (no trailing content)
        assert last_line == json.dumps(data)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
