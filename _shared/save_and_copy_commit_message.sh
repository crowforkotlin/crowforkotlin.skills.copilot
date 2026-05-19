#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:?repo root required}"
target="${2-}"

expand_path() {
  local path="$1"
  case "$path" in
    "~")
      printf '%s\n' "$HOME"
      ;;
    "~/"*)
      printf '%s/%s\n' "$HOME" "${path#~/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

copy_with_command() {
  local command_name="$1"
  shift

  if ! command -v "$command_name" >/dev/null 2>&1; then
    return 1
  fi

  if printf '%s' "$content" | "$command_name" "$@" >/dev/null 2>&1; then
    return 0
  fi

  last_error="clipboard copy failed with ${command_name}"
  return 1
}

content="$(cat)"
project_name="$(basename "$repo_root")"
last_error=""
copied=false

if [[ -n "$target" ]]; then
  target="$(expand_path "$target")"

  if [[ "$target" == */ ]] || [[ -d "$target" ]]; then
    mkdir -p "$target"
    target="${target%/}/${project_name}_commit_message.txt"
  else
    mkdir -p "$(dirname "$target")"
  fi

  printf '%s\n' "$content" > "$target"
fi

copy_with_command pbcopy && copied=true ||
copy_with_command wl-copy --type text/plain && copied=true ||
copy_with_command xclip -selection clipboard && copied=true ||
copy_with_command xsel --clipboard --input && copied=true ||
copy_with_command clip.exe && copied=true ||
copy_with_command powershell.exe -NoLogo -NoProfile -Command 'Set-Clipboard -Value ([Console]::In.ReadToEnd())' && copied=true ||
copy_with_command powershell -NoLogo -NoProfile -Command 'Set-Clipboard -Value ([Console]::In.ReadToEnd())' && copied=true ||
copy_with_command pwsh -NoLogo -NoProfile -Command 'Set-Clipboard -Value ([Console]::In.ReadToEnd())' && copied=true

if [[ "$copied" != true ]]; then
  if [[ -z "$last_error" ]]; then
    last_error="no supported clipboard command found"
  fi
  printf '%s\n' "$last_error" >&2
  exit 1
fi

if [[ -n "$target" ]]; then
  printf '%s\n' "$target"
fi
