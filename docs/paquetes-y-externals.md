---
layout: default
title: Paquetes y externals
nav_order: 5
render_with_liquid: false
---

# Paquetes y externals

Dos mecanismos distintos:

- **Paquetes del sistema** → scripts con `apt` (solo familia Debian/Ubuntu).
- **Binarios y fuentes** → `.chezmoiexternal.toml.tmpl` (chezmoi los descarga y verifica).

## Scripts

### Paquetes base — `run_onchange_before_10_install-packages.sh.tmpl`

Corre solo en `is_apt_based` y solo cuando cambia su contenido renderizado.

Lista actual:

```text
bat  build-essential  curl  fd-find  fzf  git  git-lfs  libfuse2
openssh-server  ripgrep  shellcheck  units  zsh
```

Condicionales:

| Condición | Paquete extra |
| --- | --- |
| `is_ubuntu_like` | `btop` |
| `not is_headless` | `xclip` |

El script renderiza un array y ejecuta:

```bash
PACKAGES=(
    "bat"
    # ...
)
sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"
```

Si el usuario es `root`, `sudo` se omite. En distribuciones sin `apt`, el archivo renderiza vacío.

**Añadir un paquete:** edita la lista `$packages` en el template y haz `chezmoi apply`. El cambio de
texto altera el hash y vuelve a ejecutar el script.

**Forzar la reejecución sin cambiar la lista:**

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Docker — `run_onchange_before_12_install_docker.sh.tmpl`

Corre en Linux con `apt` y sin entornos efímeros. Añade el repositorio oficial de Docker y instala
`docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin` y `docker-compose-plugin`.
Después agrega el usuario al grupo `docker` y habilita el servicio cuando systemd es PID 1.

- Si `docker` y `docker compose` ya funcionan, sale sin tocar nada.
- Mint y derivadas usan `UBUNTU_CODENAME` (Mint 22.x → `noble`), no el codename de Mint.
- No instala `docker-compose` v1; Compose v2 se usa como `docker compose`.
- Se instala también en máquinas headless: Docker es útil en servidores.

Detalle completo en [Docker](features/docker.md).

### Albert — `run_onchange_before_15_install_albert.sh.tmpl`

Instala el lanzador desde el repositorio oficial de openSUSE Build Service.

- Solo Linux y **no headless**.
- Si `albert` ya existe (`command -v`), sale sin hacer nada.
- Ramas por distro:
  - Ubuntu: `xUbuntu_24.04`, `xUbuntu_22.04`, `xUbuntu_20.04` según `ubuntuCodename`, con fallback a
    `versionID`.
  - Debian: `Debian_<versionID>`.
  - RHEL/CentOS/Alma/Rocky: repositorio `CentOS_9_Stream` + EPEL.
- Añade la clave GPG en `/etc/apt/trusted.gpg.d/` y el repo en `/etc/apt/sources.list.d/`.

Detalle completo en [Albert](features/albert.md).

### Teclado Fn — `run_onchange_before_16_fix_apple_fnkeys.sh.tmpl`

Corre en Linux no headless. Escribe `options <módulo> fnmode=2` en `/etc/modprobe.d/` y regenera el
initramfs solo si la línea no existía. Aplica el valor en caliente si el módulo está cargado.

Detalle completo en [Teclado Apple](features/teclado-apple.md).

### Starship — `run_after_20_install_starship.sh`

Se ejecuta en **cada** apply, pero es idempotente: solo descarga si falta `~/.local/bin/starship`.

```bash
if [ ! -f ~/.local/bin/starship ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
fi
```

### mise — `run_after_30_setup_mise.sh`

No instala mise (eso lo hace el external); solo genera el autocompletado de Zsh si el binario existe.

```bash
"$HOME/.local/bin/mise" completion zsh --install
```

### Shell — `run_after_90_change-shell.sh.tmpl`

Cambia el shell de login a `/usr/bin/zsh` con `chsh`. Sale sin error cuando:

- `zsh` no está instalado.
- `/usr/bin/zsh` no está en `/etc/shells`.
- Ya es el shell actual.
- No hay TTY (en ese caso imprime el comando manual).

## Externals

`.chezmoiexternal.toml.tmpl` se renderiza con `[data]` y descarga en `$HOME`.

| Destino | Origen | Refresh | Gate |
| --- | --- | --- | --- |
| `~/.local/bin/age` | `FiloSottile/age` (última release) | release | `is_ubuntu_like` |
| `~/.local/bin/age-keygen` | `FiloSottile/age` | release | `is_ubuntu_like` |
| `~/.local/bin/rbw` | `doy/rbw` | release | `is_ubuntu_like` |
| `~/.local/bin/rbw-agent` | `doy/rbw` | release | `is_ubuntu_like` |
| `~/.local/share/zsh/site-functions/_rbw` | `doy/rbw` | release | `is_ubuntu_like` |
| `~/.local/bin/eza` | `eza-community/eza` | release | `is_ubuntu_like` |
| `~/.local/bin/mise` | `jdx/mise` | 168 h | `is_ubuntu_like` |
| `~/.local/share/zinit/zinit.git` | `zdharma-continuum/zinit` | 168 h | `is_ubuntu_like` |
| `~/.local/share/fonts/MesloLGS NF *.ttf` | `romkatv/powerlevel10k-media` | 168 h | no ephemeral y no headless |

Notas:

- Todos los externals se omiten si `ephemeral = true`.
- `eza` usa un asset **x86_64**. En ARM falla; por eso Debian/Raspbian quedan fuera del bloque de
  externals (comparten el gate `is_ubuntu_like`).
- `age` se descarga pero aún no se usa para cifrar secretos; está disponible para el futuro.
- Hay entradas comentadas (`gh`, `glow`, `golangci-lint`, `jj`, `uv`, oh-my-zsh) como referencia.

### Añadir un external

```toml
[".local/bin/mi-herramienta"]
    type = "archive-file"
    url = {{ gitHubLatestReleaseAssetURL "owner/repo" (printf "tool_*_%s_%s.tar.gz" .chezmoi.os .chezmoi.arch) | quote }}
    executable = true
    path = "tool"
    refreshPeriod = "168h"
```

Aplica y verifica:

```bash
chezmoi apply --dry-run --verbose
chezmoi apply
ls -l ~/.local/bin/mi-herramienta
```

### Forzar la actualización de un external

```bash
chezmoi apply --refresh-externals
```

## Orden recomendado para una feature que necesita un binario

1. Añade el external (descarga).
2. Añade un script `run_after_*` que lo configure (autocompletado, permisos, etc.).
3. Documenta en `docs/features/<nombre>.md`.
