#!/usr/bin/env bash
# Exit 0 only when the lavish skill is installed and lavish-axi runs.
# The skills of this plugin must not run otherwise.
set -u

found=""
candidates=(
  "$HOME/.claude/skills/lavish/SKILL.md"
  "$HOME/.agents/skills/lavish/SKILL.md"
)

# Project skills: from the current folder up to the repository root.
dir="$PWD"
root="$(git rev-parse --show-toplevel 2>/dev/null || echo /)"
while :; do
  candidates+=("$dir/.claude/skills/lavish/SKILL.md" "$dir/.agents/skills/lavish/SKILL.md")
  [ "$dir" = "$root" ] || [ "$dir" = "/" ] && break
  dir="$(dirname "$dir")"
done

for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then found="$c"; break; fi
done

# A plugin that ships a skill named lavish.
if [ -z "$found" ] && [ -d "$HOME/.claude/plugins" ]; then
  found="$(find "$HOME/.claude/plugins" -path '*/skills/lavish/SKILL.md' -print -quit 2>/dev/null)"
fi

if [ -z "$found" ]; then
  echo "MISSING: the lavish skill is not installed." >&2
  echo "Install it with: npx skills add kunchenguid/lavish-axi" >&2
  echo "Source: https://github.com/kunchenguid/lavish-axi" >&2
  exit 1
fi

if ! npx -y lavish-axi --help >/dev/null 2>&1; then
  echo "MISSING: lavish-axi does not run (npx -y lavish-axi --help failed)." >&2
  echo "Check Node.js and npm, then retry. Source: https://github.com/kunchenguid/lavish-axi" >&2
  exit 1
fi

echo "OK: lavish skill at $found; lavish-axi runs."
