# AGENTS.md

## Repository layout
- Personal dotfiles managed by **chezmoi**. The git repo is `~/.local/share/chezmoi` (remote `github.com/davidreyg/dotfiles`, branch `main`); `~` itself is not a git repo.
- `.chezmoiroot` contains `home`, so the chezmoi source root is `~/.local/share/chezmoi/home` (also what `chezmoi source-path` prints). Run git commands one level up in `~/.local/share/chezmoi`.
- Managed files: `home/dot_zshrc.tmpl` -> `~/.zshrc`; `home/dot_gitconfig.tmpl` -> `~/.gitconfig`; `home/dot_config/{starship.toml,zsh/plugins.zsh,rbw/config.json}`; plus `home/.chezmoi.toml.tmpl` (chezmoi config and shared `[data]`) and `home/.chezmoiexternal.toml.tmpl` (downloads).
- `home/.chezmoiscripts/linux/` holds scripts kept out of `~`: `run_onchange_before_10_install-packages.sh.tmpl` (apt), `run_onchange_before_12_install_docker.sh.tmpl` (Docker Engine + Compose), `run_onchange_before_15_install_albert.sh.tmpl` (Albert launcher), `run_onchange_before_16_fix_apple_fnkeys.sh.tmpl` (`hid_apple`/`mac_hid` `fnmode=2`), `run_after_20_install_starship.sh`, `run_after_30_setup_mise.sh` (mise completions), `run_after_90_change-shell.sh.tmpl` (`chsh` to zsh). The `linux/` directory means they only run on Linux.
- `README.md` is the short entry point (install + collaborate). `docs/` is the modular wiki (index, instalacion, arquitectura, configuracion, paquetes-y-externals, secretos-y-ssh, troubleshooting, roadmap, agregar-feature, `features/`, `plantillas/`). `skills/agregar-feature/SKILL.md` automates adding a feature. `README.md`, `docs/` and `skills/` are outside `.chezmoiroot` and are not managed. There is no build, test suite, lint config, or CI; verification is `chezmoi apply --dry-run --verbose` plus `shellcheck` on rendered scripts.

## Commands (run on the target machine: Linux Mint 22.x, WSL Ubuntu, macOS)
- From a Windows session, use `wsl.exe -d Ubuntu-22.04 -- bash -lc '...'`. Native Windows git over `\\wsl.localhost\...` fails with "detected dubious ownership".
- `chezmoi status` and `chezmoi diff` — inspect target-vs-source drift before editing.
- `chezmoi apply --dry-run --verbose`, then `chezmoi apply` — render files and run scripts.
- `chezmoi edit ~/.zshrc` or edit `home/` directly; never hand-edit rendered files for tracked configs. Use `chezmoi re-add <path>` only to copy an intentional `~` edit back into source; `chezmoi add <path>` for new files.

## Machine/template behavior
- `home/.chezmoi.toml.tmpl` does not infer the machine type from the hostname. With a TTY, `chezmoi init` runs `promptChoice` (`personal`/`work`, default personal) every time; the non-`*Once` variant is intentional so a stale value in `[data]` cannot skip the prompt. Without a TTY it falls back to personal so provisioning still runs. Ephemeral machines skip the prompt and set `machine_type = "ephemeral"`.
- `ephemeral` (user `root` / `ubuntu` / `vagrant` / `vscode`, `CODESPACES`, `REMOTE_CONTAINERS_IPC`, `CI`, Docker/Podman containers, Windows) skips all externals and the machine-type prompt; it also skips the `chsh` script.
- Distro family flags live in `[data]`: `is_ubuntu_like` (osid `linux-ubuntu` **or** `ID_LIKE` containing `ubuntu`) gates externals, `btop` and Albert; `is_apt_based` (`is_ubuntu_like` **or** `ID` `debian`/`raspbian` **or** `ID_LIKE` containing `debian`) gates the apt script. Debian/Raspbian stay out of externals because the `eza` asset URL is x86_64-only.
- `is_headless` skips `xclip`, font downloads, Albert and the fnkeys fix. It is computed automatically: ephemeral → true; Linux → false when `systemctl get-default` is `graphical.target` or `DISPLAY`/`WAYLAND_DISPLAY` is set; macOS → false. `CHEZMOI_HEADLESS=1|0` forces it.
- `run_onchange_before_16_fix_apple_fnkeys.sh.tmpl` writes `options <hid_apple|mac_hid> fnmode=2` to `/etc/modprobe.d/`, regenerates initramfs only when the line is missing, and applies `fnmode=2` live when the module is loaded. It is safe on machines without an Apple keyboard.
- `run_onchange_before_12_install_docker.sh.tmpl` installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin` and `docker-compose-plugin` from Docker's official APT repo on apt-based non-ephemeral Linux (headless included). It uses `UBUNTU_CODENAME` for Mint/derivatives, adds the user to the `docker` group, refuses to continue if `docker.io` is installed, and enables the service only when systemd is PID 1. No new `[data]` keys, so existing machines only need `chezmoi apply`.
- Externals fetched on apply: age, age-keygen, rbw, rbw-agent, rbw zsh completion, eza, mise, and the zinit git repo; MesloLGS NF fonts only when not headless. Starship is installed by `run_after_20`, not via externals.
- `run_onchange_before_10_install-packages.sh.tmpl` runs apt only when the rendered package array changes. `run_after_90_change-shell.sh.tmpl` runs on every apply but exits early when zsh is already the login shell, is not installed, is missing from `/etc/shells`, or there is no TTY.
- After editing `home/.chezmoi.toml.tmpl` you must run `chezmoi init` (not just `apply`): the computed `[data]` block is persisted in `~/.config/chezmoi/chezmoi.toml`. Machines that pull new data keys (`is_headless`, `is_ubuntu_like`, `is_apt_based`) also need `chezmoi init` before `apply`.

## Documentation and skills
- Every user-visible feature gets a page in `docs/features/` based on `docs/plantillas/nueva-feature.md`, plus a row in the tables in `docs/features/index.md` and `docs/index.md`.
- The wiki is published with GitHub Pages from `/docs` using Just the Docs (`remote_theme` in `docs/_config.yml`; `baseurl: /dotfiles`). Every page needs YAML front matter: `layout`, `title`, `nav_order`; category pages add `has_children: true` and their children add `parent: <exact parent title>`. A page without front matter is copied unprocessed and never appears in the sidebar.
- Pages that embed Go template snippets (`{{ ... }}`) need `render_with_liquid: false` in the front matter so Jekyll/Liquid does not consume them before Markdown conversion.
- When behavior, layout, `[data]` or a gate changes, update `AGENTS.md` and the relevant page under `docs/`; update `README.md` only if installation or daily use changes.
- `docs/roadmap.md` tracks pending work; mark items done instead of deleting them silently.
- Use `skills/agregar-feature/SKILL.md` as the checklist: announce the plan, implement, verify, update `docs/` + `AGENTS.md` + `README.md`, and commit only when asked.
- Docs are in Spanish, code comments in English (script comments may be Spanish). Keep links relative so they work both in the repo and on GitHub Pages (`/docs`).

## Gotchas
- `~/.zshrc` drift was caused by a manual `# opencode` PATH export; it is now managed in `dot_zshrc.tmpl` behind `[ -d "$HOME/.opencode/bin" ]`, so `chezmoi status` is clean and `apply` no longer prompts. Never hand-edit rendered files for tracked configs.
- `chezmoi status`/`chezmoi diff` no longer list scripts because the generated config sets `status.exclude` and `diff.exclude` to `["scripts"]`.
- `home/dot_gitconfig.tmpl` hardcodes the email; the `.email` template data is defined but unused.
- `home/dot_config/starship.toml` is UTF-8 with Nerd Font glyphs and LF endings. Do not rewrite it with PowerShell/Windows tools; preserve bytes and line endings.
- Zinit plugins and external binaries are fetched from the network on apply/shell start, so the first shell is slow.
- Recent commits use Conventional Commits (`feat: ...`). Commit only when explicitly asked.
