#!/usr/bin/env bash
# Safe to re-run. Usage: ./install.sh (apply) | ./install.sh capture (refresh Brewfile from this Mac)
set -euo pipefail
TYPES=(--formula --cask --tap --mas)

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Re-run once the Command Line Tools have finished installing."
  exit 1
fi

if [[ -f ${BASH_SOURCE[0]:-} ]]; then
  DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  DOT="$HOME/dotfiles"
  [[ -d $DOT ]] || git clone https://github.com/anyset-bot/dotfiles.git "$DOT"
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

echo "==> macOS settings"
if ! mise bootstrap macos defaults status --missing >/dev/null 2>&1; then
  mise bootstrap macos defaults apply --yes
  killall Dock Finder SystemUIServer 2>/dev/null || true
  echo "   Log out and back in for trackpad, keyboard and language changes"
fi

gh auth status >/dev/null 2>&1 || echo "!! GitHub CLI not signed in: gh auth login"
[[ -f ~/.ssh/config ]] || echo "!! No ~/.ssh/config: copy it from your other Mac"
[[ -f ~/.claude/settings.json ]] || echo "!! No Claude Code settings: copy ~/.claude/settings.json from your other Mac"

echo "==> Installed but not in Brewfile (run './install.sh capture' to keep them)"
brew bundle cleanup "${TYPES[@]}" --file="$DOT/Brewfile" || true
