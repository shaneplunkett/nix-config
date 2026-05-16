#!/usr/bin/env python3
"""Vex status line for Claude Code."""

import json
import os
import subprocess
import sys


# — Catppuccin Mocha ——————————————————————————————————————————
MAUVE = (203, 166, 247)      # model
TEAL = (148, 226, 213)       # context
BLUE = (137, 180, 250)       # git branch
FLAMINGO = (242, 205, 205)   # effort level
SUBTEXT0 = (166, 173, 200)   # muted — duration
OVERLAY0 = (108, 112, 134)   # separators
GREEN = (166, 227, 161)      # diff add
RED = (243, 139, 168)        # diff remove
YELLOW = (249, 226, 175)     # context warning
PEACH = (250, 179, 135)      # context critical
# —————————————————————————————————————————————————————————————


def fg(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


def reset():
    return "\033[0m"


def git_branch(cwd):
    try:
        out = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        branch = out.stdout.strip()
        if branch:
            return branch
        # detached HEAD — short sha
        out = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        return out.stdout.strip() or None
    except Exception:
        return None


def git_diff(cwd):
    try:
        out = subprocess.run(
            ["git", "diff", "--shortstat"],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        stat = out.stdout.strip()
        if not stat:
            return None, None
        added = removed = None
        for part in stat.split(","):
            part = part.strip()
            if "insertion" in part:
                added = int(part.split()[0])
            elif "deletion" in part:
                removed = int(part.split()[0])
        return added, removed
    except Exception:
        return None, None


def format_duration(ms):
    if ms is None:
        return None
    secs = int(ms / 1000)
    if secs < 60:
        return f"{secs}s"
    mins = secs // 60
    if mins < 60:
        return f"{mins}m"
    hours = mins // 60
    remaining = mins % 60
    return f"{hours}h{remaining}m"



def format_tokens(n):
    if n is None:
        return None
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def ctx_colour(pct):
    if pct is None:
        return TEAL
    if pct >= 80:
        return PEACH
    if pct >= 60:
        return YELLOW
    return TEAL


def get_effort_level():
    """Resolve the effective effort level.

    Order of precedence (matches CC's own runtime resolution):
      1. CLAUDE_CODE_EFFORT_LEVEL env var (one-session override)
      2. settings.json/settings.local.json `effortLevel` key (set via /effort)
      3. Our tweakcc maxEffortDefault patch — for Opus 4.7 that's "max"
         even when settings.json says null

    CC does not pipe the live effort value to the statusline command (open
    feature ask), so we mirror its resolution from disk + env."""
    env_val = os.environ.get("CLAUDE_CODE_EFFORT_LEVEL")
    if env_val:
        return env_val
    claude_dir = os.path.expanduser("~/.claude")
    for fname in ("settings.local.json", "settings.json"):
        path = os.path.join(claude_dir, fname)
        try:
            with open(path) as f:
                val = json.load(f).get("effortLevel")
                if val:
                    return val
        except Exception:
            continue
    # tweakcc maxEffortDefault is on → CC starts Opus 4.7 at "max"
    return "max"


def model_short(display_name, model_id):
    name = display_name or model_id or "?"
    # "Opus 4.6 (1M context)" → "Opus 4.6 (1M)"
    name = name.replace(" context)", ")").replace(" Context)", ")")
    return name


# Auto-compaction threshold — CC defaults to ~95% of model max before triggering
# a /compact pass. Expose as a constant so the denominator stays explicit.
COMPACT_THRESHOLD_FRAC = 0.95


def model_context_limit(model_data):
    """Best-guess model max context window. Falls back to 200k for unknown."""
    display = (model_data.get("display_name") or "").lower()
    if "1m" in display:
        return 1_000_000
    return 200_000


def context_from_transcript(transcript_path):
    """Walk the CC transcript JSONL backwards, find the last assistant entry
    with a usage block, return cumulative context tokens (input + cache
    create + cache read). This is more accurate than CC's reported
    `context_window.used_percentage` which is known to lag and be wrong
    (anthropics/claude-code#12510). Returns None if anything goes sideways
    so the fallback path can take over."""
    if not transcript_path:
        return None
    try:
        with open(transcript_path) as f:
            lines = f.readlines()
    except (OSError, FileNotFoundError):
        return None

    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        if entry.get("type") != "assistant":
            continue
        # Some CC versions put usage at top-level, others nest under .message
        usage = entry.get("message", {}).get("usage") or entry.get("usage")
        if not usage:
            continue
        total = (
            usage.get("input_tokens", 0)
            + usage.get("cache_creation_input_tokens", 0)
            + usage.get("cache_read_input_tokens", 0)
        )
        if total > 0:
            return total
    return None


def main():
    raw = sys.stdin.read().strip()
    if not raw:
        return

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return

    sep = f" {fg(*OVERLAY0)}·{reset()} "
    parts = []

    # Model
    model = data.get("model", {})
    name = model_short(model.get("display_name"), model.get("id"))
    parts.append(f"{fg(*MAUVE)}{name}{reset()}")

    # Effort level — no icon, keeps visual consistency with other segments
    effort = get_effort_level()
    if effort:
        parts.append(f"{fg(*FLAMINGO)}{effort}{reset()}")

    # Context — transcript-parsed (accurate) with CC-JSON fallback.
    # Denominator is the compact threshold, not absolute model max, so the
    # % maps directly to "how close to auto-/compact". 100% = compacting.
    model_max = model_context_limit(model)
    compact_at = int(model_max * COMPACT_THRESHOLD_FRAC)
    used = context_from_transcript(data.get("transcript_path"))

    if used is not None:
        pct = int((used / compact_at) * 100)
        colour = ctx_colour(pct)
        parts.append(
            f"{fg(*colour)}{format_tokens(used)}/{format_tokens(compact_at)} {pct}%{reset()}"
        )
    else:
        # Fallback — CC's reported numbers if transcript unreadable
        ctx = data.get("context_window", {})
        pct = ctx.get("used_percentage")
        total_in = ctx.get("total_input_tokens")
        if pct is not None:
            colour = ctx_colour(pct)
            tok_str = format_tokens(total_in)
            ctx_text = f"{pct}%"
            if tok_str:
                ctx_text = f"{tok_str} {pct}%"
            parts.append(f"{fg(*colour)}{ctx_text}{reset()}")

    # Duration
    cost_data = data.get("cost", {})
    duration = format_duration(cost_data.get("total_duration_ms"))
    if duration:
        parts.append(f"{fg(*SUBTEXT0)}{duration}{reset()}")

    # Git
    cwd = data.get("cwd") or data.get("workspace", {}).get("current_dir")
    if cwd:
        branch = git_branch(cwd)
        if branch:
            parts.append(f"{fg(*BLUE)} {branch}{reset()}")

        added, removed = git_diff(cwd)
        diff_parts = []
        if added:
            diff_parts.append(f"{fg(*GREEN)}+{added}{reset()}")
        if removed:
            diff_parts.append(f"{fg(*RED)}−{removed}{reset()}")
        if diff_parts:
            parts.append(" ".join(diff_parts))

    print(sep.join(parts))


if __name__ == "__main__":
    main()
