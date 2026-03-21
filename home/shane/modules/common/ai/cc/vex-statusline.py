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
    """Read effortLevel from settings.json or settings.local.json."""
    claude_dir = os.path.expanduser("~/.claude")
    # local overrides base
    for fname in ("settings.local.json", "settings.json"):
        path = os.path.join(claude_dir, fname)
        try:
            with open(path) as f:
                val = json.load(f).get("effortLevel")
                if val:
                    return val
        except Exception:
            continue
    return None


EFFORT_ICONS = {"low": "⚡", "medium": "⚖", "high": "🧠"}


def model_short(display_name, model_id):
    name = display_name or model_id or "?"
    # "Opus 4.6 (1M context)" → "Opus 4.6 (1M)"
    name = name.replace(" context)", ")").replace(" Context)", ")")
    return name


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

    # Effort level
    effort = get_effort_level()
    if effort:
        icon = EFFORT_ICONS.get(effort, "")
        parts.append(f"{fg(*FLAMINGO)}{icon} {effort}{reset()}")

    # Context
    ctx = data.get("context_window", {})
    pct = ctx.get("used_percentage")
    total_in = ctx.get("total_input_tokens")
    colour = ctx_colour(pct)
    if pct is not None:
        tok_str = format_tokens(total_in)
        ctx_text = f"{pct}%"
        if tok_str:
            ctx_text += f" ({tok_str})"
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
