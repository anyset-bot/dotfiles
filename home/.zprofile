# Don't source ~/.zshrc here: zsh loads it right after this file
# Same as `eval "$(brew shellenv)"`, without its ~20 ms subprocess
if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew HOMEBREW_CELLAR=/opt/homebrew/Cellar HOMEBREW_REPOSITORY=/opt/homebrew
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
fi

source ~/.orbstack/shell/init.zsh 2>/dev/null || :
