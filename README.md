# dotfiles

Work Mac setup: Homebrew packages, apps, shell and tool configs.

## New Mac

```sh
git clone git@github.com:anyset-bot/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

## Day to day

- `./install.sh`: install anything missing, upgrade outdated packages, link configs. Safe to re-run.
- `./install.sh capture`: write what's installed on this Mac into `Brewfile`.

Configs in `home/` are symlinked into `~`, so edits on this Mac show up in `git diff`.
An existing file that differs is moved to `<file>.backup-<timestamp>` before linking.

## Not tracked

Secrets and keys (`~/.config/gh/hosts.yml`, `~/.config/opencode/service.json`, `~/.ssh/id_*`),
plus `~/.ssh/config` and Claude Code settings, which describe internal hosts.
