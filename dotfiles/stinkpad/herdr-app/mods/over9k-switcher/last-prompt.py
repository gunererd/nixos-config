#!/usr/bin/env python3
# Each Claude Code agent's last prompt, as JSON keyed by terminal. Which conversation
# runs where comes from over9k-prompts' claude-info.py (argv[1]); the prompt is the
# newest typed user message at the end of that conversation's transcript.
import json, os, subprocess, sys

TAIL = 2 * 1024 * 1024


def last_prompt(path):
    with open(path, "rb") as f:
        f.seek(max(0, os.path.getsize(path) - TAIL))
        lines = f.read().decode("utf-8", "replace").splitlines()
    for line in reversed(lines):
        try:
            m = json.loads(line)
        except ValueError:
            continue
        if m.get("type") != "user" or m.get("isMeta") or m.get("isCompactSummary"):
            continue
        c = m.get("message", {}).get("content")
        if isinstance(c, list):  # tool results are user messages too; typed text isn't one
            if any(b.get("type") == "tool_result" for b in c if isinstance(b, dict)):
                continue
            c = " ".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text")
        if isinstance(c, str) and c.strip() and not c.lstrip().startswith("<"):
            return " ".join(c.split())
    return None


info = json.loads(subprocess.run([sys.executable, "-I", sys.argv[1]], capture_output=True, text=True).stdout or "{}")
out = {}
for term, v in info.items():
    try:
        out[term] = last_prompt(v["transcript"])
    except (OSError, KeyError, TypeError):
        pass
print(json.dumps(out))
