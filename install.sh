#!/usr/bin/env bash
# Safe to re-run. Usage: ./install.sh (apply) | ./install.sh capture (refresh Brewfile from this Mac)
set -euo pipefail
DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TYPES=(--formula --cask --tap --mas)

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Re-run once the Command Line Tools have finished installing."
  exit 1
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ ${1:-} == capture ]]; then
  brew bundle dump "${TYPES[@]}" --file="$DOT/Brewfile" --force
  sed -i '' '/^#/d' "$DOT/Brewfile"
  git -C "$DOT" diff --stat -- Brewfile
  exit
fi

echo "==> Packages"
brew bundle --file="$DOT/Brewfile" || echo "!! Some entries failed (App Store apps need you signed in to the App Store)"

echo "==> Config files"
cd "$DOT/home"
find . \( -type f -o -type l \) -not -name .DS_Store -print0 | while IFS= read -r -d '' rel; do
  rel=${rel#./}
  src="$DOT/home/$rel"
  dst="$HOME/$rel"
  [[ -L $dst && $(readlink "$dst") == "$src" ]] && continue
  mkdir -p "$(dirname "$dst")"
  if [[ -L $dst ]] || { [[ -e $dst ]] && cmp -s "$src" "$dst"; }; then
    rm "$dst"
  elif [[ -e $dst ]]; then
    mv "$dst" "$dst.backup-$(date +%Y%m%d-%H%M%S)"
    echo "   backed up ~/$rel"
  fi
  ln -s "$src" "$dst"
  echo "   linked ~/$rel"
done

echo "==> mise tools"
mise install || echo "!! mise install failed for some tools"

echo "==> Installed but not in Brewfile (run './install.sh capture' to keep them)"
brew bundle cleanup "${TYPES[@]}" --file="$DOT/Brewfile" || true
