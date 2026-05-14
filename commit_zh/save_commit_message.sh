#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:?repo root required}"
target="${2:?target path required}"

case "$target" in
  "~")
    target="$HOME"
    ;;
  "~/"*)
    target="$HOME/${target#~/}"
    ;;
esac

content="$(cat)"
project_name="$(basename "$repo_root")"

if [[ "$target" == */ ]] || [[ -d "$target" ]]; then
  mkdir -p "$target"
  target="${target%/}/${project_name}_commit_message.txt"
else
  mkdir -p "$(dirname "$target")"
fi

printf '%s\n' "$content" > "$target"
printf '%s\n' "$target"
