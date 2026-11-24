#!/bin/bash
# Status line layout: model, directory name, git branch, context usage %.

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

bold=$'\033[1;36m'
italic=$'\033[3;36m'
cyan=$'\033[36m'
reset=$'\033[0m'

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

out=""
add() { out="${out:+$out }$1"; }

[ -n "$model" ] && add "${cyan}${model}${reset}"

dir=$(basename "${cwd:-$PWD}")
add "${bold}${dir}${reset}"

branch=$(git --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null \
  || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && add "${italic}${branch}${reset}"

if [ -n "$used" ]; then
  add "${cyan}$(printf '%.0f' "$used")%${reset}"
else
  add "${cyan}0%${reset}"
fi

printf '%s\n' "$out"
