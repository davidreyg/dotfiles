# AGENTS.md

## Repository layout
- Personal dotfiles managed by **chezmoi**. The git repo is `~/.local/share/chezmoi` (remote `github.com/davidreyg/dotfiles`, branch `main`); `~` itself is not a git repo.
- `.chezmoiroot` contains `home`, so the chezmoi source root is `~/.local/share/chezmoi/home` (also what `chezmoi source-path` prints). Run git commands one level up in `~/.local/share/chezmoi`.
- Managed files: `home/dot_zshrc.tmpl` -> `~/.zshrc`; `home/dot_gitconfig.tmpl` -> `~/.gitconfig`; `home/dot_config/{starship.toml,zsh/plugins.zsh,rbw/config.json}`; plus `home/.chezmoi.toml.tmpl` (chezmoi config) and `home/.chezmoiexternal.toml.tmpl` (downloads).
- `home/.chezmoiscripts/linux/` holds scripts kept out of `~`: `run_before_10_install-packages.sh.tmpl` (apt), `run_after_20_install_starship.sh`, `run_onchange_after_90_change-shell.sh.tmpl` (`chsh` to zsh). The `linux/` directory means they only run on Linux.
- No README, build, tests, lint config, or CI. Verification is `chezmoi apply --dry-run --verbose` plus `shellcheck` on scripts.

## Commands (run in WSL Ubuntu)
- From a Windows session, use `wsl.exe -d Ubuntu-22.04 -- bash -lc '...'`. Native Windows git over `\\wsl.localhost\...` fails with "detected dubious ownership".
- `chezmoi status` and `chezmoi diff` — inspect target-vs-source drift before editing.
- `chezmoi apply --dry-run --verbose`, then `chezmoi apply` — render files and run scripts.
- `chezmoi edit ~/.zshrc` or edit `home/` directly; never hand-edit rendered files for tracked configs. Use `chezmoi re-add <path>` only to copy an intentional `~` edit back into source; `chezmoi add <path>` for new files.

## Machine/template behavior
- `home/.chezmoi.toml.tmpl` sets data from hostname: `daregu-pc` / `macbook-air-m3` = personal; `ubuntu` / `ubuntu-26` = headless + personal; `zrh-mpl3s` = work. Unknown hosts prompt; non-interactive runs become `ephemeral` and `headless`.
- `ephemeral` (also user `root` / `ubuntu` / `vagrant` / `vscode`, `CODESPACES`, `REMOTE_CONTAINERS_IPC`, Windows) skips all externals and the `chsh` script.
- `headless` skips `xclip` and font downloads. `osid` (e.g. `linux-ubuntu`) gates Ubuntu-only externals and packages; the package script also targets `linux-debian` and `linux-raspbian`.
- Externals fetched on apply: age, age-keygen, rbw, rbw-agent, rbw zsh completion, eza, and the zinit git repo; MesloLGS NF fonts only when not headless. Starship is installed by `run_after_20`, not via externals.

## Gotchas
- `~/.zshrc` has drift: the rendered file sources `~/.config/zsh/aliases.zsh`, which is unmanaged and absent from the source tree, while `dot_zshrc.tmpl` does not. `chezmoi apply` removes that line; don't assume `~` is authoritative. `chezmoi status` also lists the scripts as `R` (would run).
- `home/dot_gitconfig.tmpl` hardcodes the email; the `.email` template data is defined but unused.
- `home/dot_config/starship.toml` is UTF-8 with Nerd Font glyphs and LF endings. Do not rewrite it with PowerShell/Windows tools; preserve bytes and line endings.
- Zinit plugins and external binaries are fetched from the network on apply/shell start, so the first shell is slow.
- Recent commits use Conventional Commits (`feat: ...`). Commit only when explicitly asked.
