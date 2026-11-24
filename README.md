# dotfiles

Work Mac setup: Homebrew packages, apps, shell and tool configs.

## New Mac

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anyset-bot/dotfiles/main/install.sh)"
```

It clones this repo to `~/dotfiles` and runs `install.sh` from there. Sign in to the App Store first so the App Store apps install.

## Day to day

- `./install.sh`: install anything missing, upgrade outdated packages, link configs. Safe to re-run.
- `./install.sh capture`: write what's installed on this Mac into `Brewfile`.

Configs in `home/` are symlinked into `~`, so edits on this Mac show up in `git diff`.
An existing file that differs is moved to `<file>.backup-<timestamp>` before linking.

macOS settings (Dock, Finder, trackpad, languages, Rectangle, login items) live in
`home/.config/mise/conf.d/macos.toml`. `mise bootstrap macos defaults status` shows any drift.

## Not tracked

Secrets and keys (`~/.config/gh/hosts.yml`, `~/.config/opencode/service.json`, `~/.ssh/id_*`),
plus `~/.ssh/config` and Claude Code settings, which describe internal hosts.
