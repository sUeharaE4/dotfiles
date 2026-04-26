#!/usr/bin/env python3
"""Conservative Codex PermissionRequest policy for local development checks."""

from __future__ import annotations

import json
import re
import shlex
import sys
from typing import Any, List, Optional


DENY_PATTERNS = [
    r"\brm\s+-[^;&|]*r[^;&|]*f\b",
    r"\bgit\s+reset\s+--hard\b",
    r"\bgit\s+clean\b",
    r"\bgit\s+push\b.*\s--force(?:-with-lease)?\b",
    r"\bgit\s+push\b.*\s--mirror\b",
    r"\bgh\s+pr\s+merge\b",
    r"\bgh\s+release\b",
    r"\bnpm\s+publish\b",
    r"\bpnpm\s+publish\b",
    r"\byarn\s+npm\s+publish\b",
    r"\bbun\s+publish\b",
    r"\bcargo\s+publish\b",
    r"\btwine\s+upload\b",
    r"\bvercel\b.*\s--prod\b",
    r"\bfly\s+deploy\b",
    r"\bfirebase\s+deploy\b",
    r"\bnetlify\s+deploy\b.*\s--prod\b",
    r"\bterraform\s+(apply|destroy)\b",
    r"\bkubectl\s+(apply|delete|rollout|scale)\b",
    r"\b(push-protection|secret-scanning)\b.*\b(bypass|disable|skip)\b",
]

PUBLIC_EXPOSURE_PATTERNS = [
    r"\bngrok\b",
    r"\bcloudflared\s+tunnel\b",
    r"\blocaltunnel\b",
    r"\blt\s+--port\b",
    r"(--host|--hostname|--listen|--bind)\s+0\.0\.0\.0\b",
]

SAFE_NPM_SCRIPTS = {
    "test",
    "test:unit",
    "test:integration",
    "test:e2e",
    "spec",
    "check",
    "lint",
    "lint:fix",
    "format",
    "format:check",
    "typecheck",
    "type-check",
    "build",
    "dev",
    "start",
    "preview",
    "storybook",
}

SAFE_DIRECT_COMMANDS = {
    "pytest",
    "rspec",
    "rubocop",
    "eslint",
    "prettier",
    "tsc",
    "vite",
    "vitest",
    "jest",
    "next",
    "nuxt",
    "astro",
    "cargo",
    "go",
    "mix",
    "dotnet",
    "swift",
    "xcodebuild",
    "rails",
    "django-admin",
    "uvicorn",
}


def emit_allow() -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {"behavior": "allow"},
                }
            }
        )
    )


def emit_deny(message: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {"behavior": "deny", "message": message},
                }
            }
        )
    )


def normalize_command(command: str) -> str:
    command = command.strip()
    try:
        parts = shlex.split(command)
    except ValueError:
        return command

    if len(parts) >= 3 and parts[0] in {"bash", "zsh", "sh"} and parts[1] in {"-c", "-lc", "-ic"}:
        return parts[2].strip()
    return command


def split_words(command: str) -> List[str]:
    try:
        return shlex.split(command)
    except ValueError:
        return []


def has_pattern(command: str, patterns: list[str]) -> bool:
    return any(re.search(pattern, command) for pattern in patterns)


def script_name(words: List[str]) -> Optional[str]:
    if not words:
        return None

    if words[0] in {"npm", "pnpm", "bun"}:
        if len(words) >= 2 and words[1] == "run" and len(words) >= 3:
            return words[2]
        if len(words) >= 2 and words[1] in {"test", "start"}:
            return words[1]

    if words[0] == "yarn":
        if len(words) >= 2 and words[1] == "run" and len(words) >= 3:
            return words[2]
        if len(words) >= 2:
            return words[1]

    return None


def is_safe_script(script: str) -> bool:
    return script in SAFE_NPM_SCRIPTS or any(
        script.startswith(prefix + ":") for prefix in {"test", "lint", "typecheck", "type-check", "build"}
    )


def is_safe_direct_command(words: List[str]) -> bool:
    if not words:
        return False

    cmd = words[0]

    if cmd == "python" or cmd == "python3":
        return len(words) >= 3 and words[1] == "-m" and words[2] in {"pytest", "unittest"}

    if cmd == "uv":
        return len(words) >= 3 and words[1] == "run" and words[2] in {"pytest", "ruff", "mypy"}

    if cmd == "poetry":
        return len(words) >= 3 and words[1] == "run" and words[2] in {"pytest", "ruff", "mypy"}

    if cmd == "bundle":
        return len(words) >= 3 and words[1] == "exec" and words[2] in {"rspec", "rubocop", "rails", "rake"}

    if cmd == "cargo":
        return len(words) >= 2 and words[1] in {"test", "check", "clippy", "build", "run"}

    if cmd == "go":
        return len(words) >= 2 and words[1] in {"test", "vet", "build", "run"}

    if cmd == "mix":
        return len(words) >= 2 and words[1] in {"test", "format", "compile"}

    if cmd == "dotnet":
        return len(words) >= 2 and words[1] in {"test", "build", "run"}

    if cmd == "swift":
        return len(words) >= 2 and words[1] in {"test", "build", "run"}

    if cmd == "xcodebuild":
        return "test" in words or "build" in words

    if cmd == "rails":
        return len(words) >= 2 and words[1] in {"server", "s", "test"}

    if cmd == "django-admin":
        return len(words) >= 2 and words[1] in {"runserver", "test"}

    return cmd in SAFE_DIRECT_COMMANDS


def should_allow(command: str) -> bool:
    command = normalize_command(command)
    lowered = command.lower()

    if has_pattern(lowered, DENY_PATTERNS):
        return False

    if has_pattern(lowered, PUBLIC_EXPOSURE_PATTERNS):
        return False

    # Keep chained commands interactive unless every segment is plainly a local check.
    if re.search(r"\s(&&|\|\||;|\|)\s", command):
        return False

    words = split_words(command)
    if not words:
        return False

    script = script_name(words)
    if script:
        return is_safe_script(script)

    return is_safe_direct_command(words)


def main() -> int:
    try:
        payload: dict[str, Any] = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    tool_input = payload.get("tool_input") or {}
    command = tool_input.get("command")
    if not isinstance(command, str) or not command.strip():
        return 0

    normalized = normalize_command(command)
    lowered = normalized.lower()

    if has_pattern(lowered, DENY_PATTERNS) or has_pattern(lowered, PUBLIC_EXPOSURE_PATTERNS):
        emit_deny("Blocked by Codex command approval policy. This command is destructive, publishing-related, public-facing, or security-bypass related.")
        return 0

    if should_allow(normalized):
        emit_allow()
        return 0

    # No decision: let Codex use the normal approval flow.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
