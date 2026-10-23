# dotfiles

Configuración personal de shell, herramientas de línea de comandos y secretos, gestionada con
[chezmoi](https://www.chezmoi.io/). Un solo comando deja una máquina Linux recién instalada lista
para trabajar: Zsh con Zinit, prompt de Starship, utilidades modernas, Git configurado y acceso SSH a
GitHub mediante [rbw](https://github.com/doy/rbw) (cliente no oficial de Bitwarden).

![managed with chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)
![platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)
![shell](https://img.shields.io/badge/shell-zsh-89e051)

---

## Tabla de contenido

- [Qué incluye](#qué-incluye)
- [Plataformas soportadas](#plataformas-soportadas)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Configurar rbw y SSH para GitHub](#configurar-rbw-y-ssh-para-github)
- [Verificación posterior](#verificación-posterior)
- [Uso diario](#uso-diario)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Perfiles de máquina y plantillas](#perfiles-de-máquina-y-plantillas)
- [Personalización](#personalización)
- [Solución de problemas](#solución-de-problemas)
- [Seguridad](#seguridad)
- [Roadmap](#roadmap)
- [Convenciones](#convenciones)

---

## Qué incluye

| Componente | Detalle |
| --- | --- |
| **Zsh** | Historial compartido entre sesiones, completado insensible a mayúsculas, `PATH` para `~/bin`, `~/.local/bin` y `~/.opencode/bin`. |
| **Zinit** | Gestor de plugins: `fast-syntax-highlighting`, `zsh-autosuggestions`, `fzf-tab`, `zsh-you-should-use`, `zsh-eza` y snippets de Oh My Zsh (git, docker, man pages). |
| **Starship** | Prompt instalado en `~/.local/bin` y cargado de forma diferida por Zinit. |
| **rbw** | Cliente de Bitwarden + `rbw-agent` como agente SSH (`$XDG_RUNTIME_DIR/rbw/ssh-agent-socket`). |
| **eza / bat / ripgrep / fd / fzf / btop** | Utilidades de línea de comandos instaladas por el script de paquetes. |
| **Fuentes** | MesloLGS NF (solo en máquinas con pantalla) para glifos de Nerd Font. |
| **Git** | `user.name`, `user.email` y `init.defaultBranch = main`. |

Todo se renderiza con plantillas de chezmoi según el perfil de la máquina, por lo que el mismo
repositorio sirve para un portátil personal, un servidor sin pantalla o un contenedor desechable.

## Plataformas soportadas

| Plataforma | Estado | Notas |
| --- | --- | --- |
| Debian / Ubuntu / Linux Mint / Pop!_OS / Zorin / Raspbian | ✅ Soportado | Detección vía `os-release` (`ID_LIKE=ubuntu`). Instalación con `apt`. |
| Ubuntu en WSL | ✅ Soportado | Se detecta como entorno headless; no instala `xclip` ni fuentes. |
| macOS | ⚠️ Parcial | Se aplican los archivos de configuración y las fuentes, pero no hay bootstrap de paquetes (Homebrew). |
| Windows (nativo) | ❌ No soportado | Se detecta como efímero y se omite todo lo externo. Usar WSL. |
| Contenedores / CI / Codespaces | ⚠️ Efímero | Se omiten binarios externos, fuentes y `chsh`; solo se escriben configuraciones. |

Probado con chezmoi `v2.73.3` sobre Linux Mint 22.x y Ubuntu 22.04 (WSL).

## Requisitos

Antes de empezar, la máquina necesita:

- `curl` y `git` (el script de paquetes los instala, pero chezmoi los necesita **antes**).
- `sudo` con permisos de administrador (instalación de paquetes y `chsh`).
- Acceso a internet (GitHub para binarios y plugins; Bitwarden para los secretos).
- Una cuenta de Bitwarden con una **clave SSH** guardada como elemento de tipo *SSH key*.

En Debian/Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y curl git ca-certificates
```

## Instalación

### 1. Instalar chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
```

El binario queda en `~/bin`, que ya está en el `PATH` de este repositorio. Verifica la instalación:

```bash
exec zsh -l        # recarga el PATH
chezmoi --version
```

> En macOS puedes usar `brew install chezmoi` en lugar del script.

### 2. Sincronizar este repositorio

```bash
chezmoi init --apply davidreyg/dotfiles
```

Este comando clona el repositorio en `~/.local/share/chezmoi` y aplica todo. Durante la primera
ejecución:

1. Pide la contraseña de `sudo` para instalar paquetes con `apt`.
2. Descarga `age`, `age-keygen`, `rbw`, `rbw-agent`, `eza` y el repositorio de Zinit.
3. Instala Starship en `~/.local/bin`.
4. Descarga las fuentes MesloLGS NF (si la máquina tiene pantalla).
5. Pregunta si quieres cambiar el shell por defecto a `/usr/bin/zsh`.

Si prefieres revisar antes de aplicar:

```bash
chezmoi init davidreyg/dotfiles
chezmoi diff                    # ver qué cambiaría
chezmoi apply --dry-run --verbose
chezmoi apply
```

Al terminar, abre una sesión nueva (o `exec zsh`) y confirma el estado:

```bash
chezmoi status      # debe estar vacío
chezmoi doctor
```

## Configurar rbw y SSH para GitHub

**Este paso es obligatorio.** La clave SSH que autoriza los pushes a este repositorio vive en
Bitwarden, así que hasta que rbw no esté registrado y desbloqueado no podrás subir cambios.

### 1. Registrar el dispositivo

Obtén las credenciales en el vault web: **Settings → Security → Keys → View API key**. Necesitas:

- `client_id` (empieza por `user.`)
- `client_secret`

```bash
rbw register
```

El comando pedirá el correo (ya viene en `~/.config/rbw/config.json`), el `client_id` y el
`client_secret`. No uses la contraseña maestra aquí: `register` existe precisamente para evitar la
detección de bots de Bitwarden.

### 2. Iniciar sesión

```bash
rbw login
```

Introduce la contraseña maestra y el código 2FA si está activado.

### 3. Desbloquear y arrancar el agente

```bash
rbw unlock
```

Esto descifra la base local y arranca `rbw-agent`, que expone las claves SSH en
`$XDG_RUNTIME_DIR/rbw/ssh-agent-socket` (ruta configurada en `~/.zshrc`).

### 4. Comprobar que el agente SSH funciona

Abre una shell nueva para cargar `SSH_AUTH_SOCK` y verifica:

```bash
echo "$SSH_AUTH_SOCK"        # .../rbw/ssh-agent-socket
rbw unlocked                 # exit code 0
ssh-add -l                   # lista tu clave SSH
ssh -T git@github.com
```

Salida esperada:

```text
Hi davidreyg! You've successfully authenticated, but GitHub does not provide shell access.
```

Si `ssh-add -l` responde *"The agent has no identities"*, la clave no está guardada como elemento
**SSH key** en Bitwarden o el agente no está corriendo: vuelve a ejecutar `rbw unlock`.

### 5. Probar un cambio real

```bash
chezmoi cd
git pull
git status
```

Si el `pull` funciona por SSH, ya puedes editar y publicar cambios.

> `rbw unlock` debe repetirse después de cada reinicio o de que el agente se detenga. El desbloqueo
> automático con una unidad de systemd está en el [roadmap](#roadmap).

## Verificación posterior

Checklist de una instalación correcta:

```bash
chezmoi status                  # sin diferencias
chezmoi doctor                  # sin errores críticos
echo "$SHELL"                   # /usr/bin/zsh
starship --version              # instalado
eza --version                   # instalado
rbw unlocked                    # base desbloqueada
ssh -T git@github.com           # autenticación correcta
```

## Uso diario

| Comando | Para qué sirve |
| --- | --- |
| `chezmoi status` | Ver archivos con diferencias entre origen y destino. |
| `chezmoi diff` | Ver el contenido exacto de esas diferencias. |
| `chezmoi apply --dry-run --verbose` | Simular la aplicación sin tocar nada. |
| `chezmoi apply` | Aplicar cambios del repositorio a la máquina. |
| `chezmoi update` | `git pull` + `apply` (traer cambios desde GitHub). |
| `chezmoi edit ~/.zshrc` | Editar un archivo gestionado (edita el origen, no el destino). |
| `chezmoi cd` | Abrir una subshell en `~/.local/share/chezmoi`. |
| `chezmoi add ~/.config/foo` | Empezar a gestionar un archivo nuevo. |
| `chezmoi re-add ~/.zshrc` | Copiar a origen un cambio hecho a mano en el destino. |
| `chezmoi forget ~/.config/foo` | Dejar de gestionar un archivo. |

Regla de oro: **no edites a mano archivos gestionados** (`~/.zshrc`, `~/.gitconfig`, …). Usa
`chezmoi edit` y luego `chezmoi apply`; de lo contrario `chezmoi status` mostrará deriva.

## Estructura del repositorio

```text
.
├── .chezmoiroot                      # raíz de origen = home/
├── AGENTS.md                         # notas para agentes/IA
├── README.md
└── home/
    ├── .chezmoi.toml.tmpl            # configuración y [data] calculada
    ├── .chezmoiexternal.toml.tmpl    # binarios y fuentes descargados
    ├── .chezmoitemplates/
    │   └── ubuntu-like.tmpl          # detección de la familia Ubuntu
    ├── .chezmoiscripts/linux/
    │   ├── run_onchange_before_10_install-packages.sh.tmpl
    │   ├── run_after_20_install_starship.sh
    │   └── run_after_90_change-shell.sh.tmpl
    ├── dot_zshrc.tmpl                # -> ~/.zshrc
    ├── dot_gitconfig.tmpl            # -> ~/.gitconfig
    └── dot_config/
        ├── starship.toml             # -> ~/.config/starship.toml
        ├── rbw/config.json           # -> ~/.config/rbw/config.json
        └── zsh/plugins.zsh           # -> ~/.config/zsh/plugins.zsh
```

Convenciones de chezmoi:

- `dot_` se convierte en `.` al aplicar (`dot_zshrc.tmpl` → `~/.zshrc`).
- El sufijo `.tmpl` indica plantilla Go, renderizada con los datos de `[data]`.
- `run_` ejecuta scripts en la máquina destino (`before_`/`after_` y `once`/`onchange` controlan el
  orden y la frecuencia). El subdirectorio `linux/` limita su ejecución a Linux.

## Perfiles de máquina y plantillas

`home/.chezmoi.toml.tmpl` calcula estas variables:

| Variable | Significado |
| --- | --- |
| `headless` | Sin pantalla ni teclado: omite `xclip` y las fuentes. |
| `ephemeral` | Máquina desechable: omite binarios externos, fuentes y `chsh`. |
| `personal` | Máquina personal con acceso a secretos. |
| `work` | Máquina de trabajo. |
| `osid` | Identificador de distro, p. ej. `linux-linuxmint`. |
| `hostname` | Hostname efectivo (en macOS vía `scutil`). |

Perfiles conocidos:

| Hostname | Perfil |
| --- | --- |
| `daregu-pc`, `macbook-air-m3` | Personal |
| `ubuntu`, `ubuntu-26` | Headless + personal |
| `zrh-mpl3s` | Trabajo |
| Desconocido con TTY | Pregunta por `headless` y `ephemeral` |
| Desconocido sin TTY | Asume estación de trabajo personal (permite aprovisionar) |

Se consideran efímeros, sin preguntar: usuarios `root`, `ubuntu`, `vagrant`, `vscode`; variables
`CODESPACES`, `REMOTE_CONTAINERS_IPC`, `CI`; contenedores Docker/Podman y Windows nativo.

> Después de editar `.chezmoi.toml.tmpl` ejecuta `chezmoi init`, no solo `chezmoi apply`: el bloque
> `[data]` calculado se persiste en `~/.config/chezmoi/chezmoi.toml`.

## Personalización

### Añadir un paquete del sistema

Edita la lista `$packages` en
`home/.chezmoiscripts/linux/run_onchange_before_10_install-packages.sh.tmpl`. El script se vuelve a
ejecutar automáticamente cuando cambia el archivo renderizado.

Para forzar una reejecución sin tocar la lista:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Añadir un binario externo

Añade una entrada en `home/.chezmoiexternal.toml.tmpl` y aplica. Para binarios de GitHub usa
`gitHubLatestReleaseAssetURL` (ya se usa para `age`, `rbw` y `eza`).

### Añadir un archivo de configuración

```bash
chezmoi add ~/.config/mi-herramienta/config.toml
chezmoi cd
git add .
git commit -m "feat: manage mi-herramienta config"
git push
```

## Solución de problemas

| Síntoma | Causa / solución |
| --- | --- |
| `chezmoi: command not found` | Abre una shell nueva; el binario está en `~/bin`, añadido al `PATH` por `.zshrc`. |
| La primera shell tarda mucho | Zinit clona plugins en el primer arranque. Las siguientes son rápidas. |
| Se omitió el cambio de shell | Sin TTY o `zsh` no está en `/etc/shells`. Ejecuta `chsh -s /usr/bin/zsh`. |
| `ssh -T git@github.com` da *Permission denied* | Falta `rbw unlock`, la clave no está en Bitwarden, o `SSH_AUTH_SOCK` no apunta al socket de rbw. |
| `rbw` no pide la contraseña correctamente | Sin entorno gráfico, usa `rbw config set pinentry pinentry-tty`. |
| El agente quedó en mal estado | `rbw stop-agent && rbw unlock`. |
| Falla la descarga de `eza` | La URL es `x86_64`; en ARM no hay asset y el external falla. |
| El script de paquetes no corre | Solo se ejecuta al cambiar su contenido renderizado. Usa `chezmoi state delete-bucket --bucket=scriptState`. |
| `chezmoi status` no lista los scripts | Comportamiento intencional: `status.exclude` y `diff.exclude` incluyen `scripts`. |

Diagnóstico general:

```bash
chezmoi doctor
chezmoi apply --dry-run --verbose
```

## Seguridad

- **No hay secretos en el repositorio.** `~/.config/rbw/config.json` solo contiene el correo; la
  contraseña maestra y la clave SSH permanecen en Bitwarden.
- La clave SSH se sirve bajo demanda desde `rbw-agent` mediante un socket en `$XDG_RUNTIME_DIR`, con
  permisos del usuario y vida limitada a la sesión.
- El binario `age` se descarga y queda disponible para cifrar secretos con chezmoi en el futuro; hoy
  no se usa ningún archivo `.age`.
- Si el repositorio pasara a ser privado, el clonado inicial requeriría un token; los pushes ya
  usan SSH.

## Roadmap

- [ ] **Brave Browser** — añadir el repositorio APT oficial (o snap) en el script de paquetes.
- [ ] **OpenCode** — instalar con el script oficial en `~/.opencode/bin` (el `PATH` ya está previsto en `.zshrc`).
- [ ] **Visual Studio Code** — repositorio APT de Microsoft con clave firmada; alternativa: snap `--classic`.
- [ ] **Desbloqueo automático de rbw** — unidad de usuario de systemd para arrancar `rbw-agent` al iniciar sesión.
- [ ] **Soporte macOS completo** — bootstrap con Homebrew y `chsh` equivalente.
- [ ] **CI de validación** — `chezmoi apply --dry-run` y `shellcheck` en cada push.
- [ ] **Backup verificado de secretos** — documentar la recuperación del vault y de la clave SSH.

## Convenciones

- Commits en formato [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`,
  `refactor:`, `docs:`.
- Rama principal: `main`.
- Antes de publicar: `chezmoi apply --dry-run --verbose` y `shellcheck` sobre los scripts.

---

Uso personal. El código se publica tal cual, sin garantías ni licencia explícita.
