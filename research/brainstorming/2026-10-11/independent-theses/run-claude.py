"""Run one bounded, read-only Claude brainstorming round and save its response."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("round", type=int, choices=range(1, 5))
args = parser.parse_args()
directory = Path(__file__).resolve().parent
prompt = (directory / f"claude-round-{args.round}-prompt.txt").read_text()
command = [
    "claude", "-p", "--model", "claude-opus-5-5", "--effort", "high",
    "--tools", "Read,Glob,Grep", "--allowedTools", "Read,Glob,Grep",
    "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}',
    "--no-session-persistence", "--output-format", "json",
]
result = subprocess.run(command, input=prompt, text=True, capture_output=True,
                        cwd=directory.parents[3])
if result.returncode:
    print(result.stderr or result.stdout)
    raise SystemExit(result.returncode)
payload = json.loads(result.stdout)
(directory / f"claude-round-{args.round}.json").write_text(
    json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
if payload.get("is_error"):
    print(payload.get("result", "Claude returned an error"))
    raise SystemExit(1)
models = list(payload.get("modelUsage", {}))
if models != ["claude-opus-5-5"]:
    print(json.dumps({"unexpected_models": models}))
    raise SystemExit(2)
(directory / f"claude-round-{args.round}.md").write_text(payload["result"] + "\n")
print(json.dumps({"round": args.round, "model": models[0], "effort_requested": "high",
                  "duration_ms": payload.get("duration_ms"), "is_error": False}))
