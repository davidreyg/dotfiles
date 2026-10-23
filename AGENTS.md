# AGENTS.md

## Repository layout
- Personal dotfiles managed by **chezmoi**. The git repo is `~/.local/share/chezmoi` (remote `github.com/davidreyg/dotfiles`, branch `main`); `~` itself is not a git repo.
- `.chezmoiroot` contains `home`, so the chezmoi source root is `~/.local/share/chezmoi/home` (also what `chezmoi source-path` prints). Run git commands one level up in `~/.local/share/chezmoi`.
- Managed files: `home/dot_zshrc.tmpl` -> `~/.zshrc`; `home/dot_gitconfig.tmpl` -> `~/.gitconfig`; `home/dot_config/{starship.toml,zsh/plugins.zsh,rbw/config.json}`; plus `home/.chezmoi.toml.tmpl` (chezmoi config), `home/.chezmoiexternal.toml.tmpl` (downloads) and `home/.chezmoitemplates/ubuntu-like.tmpl` (shared gate for the Debian/Ubuntu family).
- `home/.chezmoiscripts/linux/` holds scripts kept out of `~`: `run_onchange_before_10_install-packages.sh.tmpl` (apt), `run_after_20_install_starship.sh`, `run_after_90_change-shell.sh.tmpl` (`chsh` to zsh). The `linux/` directory means they only run on Linux.
- No README, build, tests, lint config, or CI. Verification is `chezmoi apply --dry-run --verbose` plus `shellcheck` on scripts.

## Commands (run on the target machine: Linux Mint 22.x, WSL Ubuntu, macOS)
- From a Windows session, use `wsl.exe -d Ubuntu-22.04 -- bash -lc '...'`. Native Windows git over `\\wsl.localhost\...` fails with "detected dubious ownership".
- `chezmoi status` and `chezmoi diff` — inspect target-vs-source drift before editing.
- `chezmoi apply --dry-run --verbose`, then `chezmoi apply` — render files and run scripts.
- `chezmoi edit ~/.zshrc` or edit `home/` directly; never hand-edit rendered files for tracked configs. Use `chezmoi re-add <path>` only to copy an intentional `~` edit back into source; `chezmoi add <path>` for new files.

## Machine/template behavior
- `home/.chezmoi.toml.tmpl` sets data from hostname: `daregu-pc` / `macbook-air-m3` = personal; `ubuntu` / `ubuntu-26` = headless + personal; `zrh-mpl3s` = work. Known hosts never prompt. Unknown hosts prompt for `headless`/`ephemeral` when there is a TTY; **without a TTY they are treated as a personal workstation** (not ephemeral) so provisioning still happens.
- `ephemeral` (user `root` / `ubuntu` / `vagrant` / `vscode`, `CODESPACES`, `REMOTE_CONTAINERS_IPC`, `CI`, Docker/Podman containers, Windows) skips all externals; it also skips the `chsh` script.
- `headless` skips `xclip` and font downloads. `osid` (e.g. `linux-linuxmint`) identifies the distro; the Debian/Ubuntu family check lives in `home/.chezmoitemplates/ubuntu-like.tmpl`, which matches `osid == linux-ubuntu` **or** `ID_LIKE` containing `ubuntu` (Linux Mint, Pop!_OS, Zorin, ...). The package script also targets `linux-debian` and `linux-raspbian`; those two are intentionally excluded from externals because the `eza` asset URL is x86_64-only.
- Externals fetched on apply: age, age-keygen, rbw, rbw-agent, rbw zsh completion, eza, and the zinit git repo; MesloLGS NF fonts only when not headless. Starship is installed by `run_after_20`, not via externals.
- `run_onchange_before_10_install-packages.sh.tmpl` runs apt only when the package list changes. `run_after_90_change-shell.sh.tmpl` runs on every apply but exits early when zsh is already the login shell, is not installed, is missing from `/etc/shells`, or there is no TTY.
- After editing `home/.chezmoi.toml.tmpl` you must run `chezmoi init` (not just `apply`): the computed `[data]` block is persisted in `~/.config/chezmoi/chezmoi.toml`.

## Gotchas
- `~/.zshrc` drift was caused by a manual `# opencode` PATH export; it is now managed in `dot_zshrc.tmpl` behind `[ -d "$HOME/.opencode/bin" ]`, so `chezmoi status` is clean and `apply` no longer prompts. Never hand-edit rendered files for tracked configs.
- `chezmoi status`/`chezmoi diff` no longer list scripts because the generated config sets `status.exclude` and `diff.exclude` to `["scripts"]`.
- `home/dot_gitconfig.tmpl` hardcodes the email; the `.email` template data is defined but unused.
- `home/dot_config/starship.toml` is UTF-8 with Nerd Font glyphs and LF endings. Do not rewrite it with PowerShell/Windows tools; preserve bytes and line endings.
- Zinit plugins and external binaries are fetched from the network on apply/shell start, so the first shell is slow.
- Recent commits use Conventional Commits (`feat: ...`). Commit only when explicitly asked.
