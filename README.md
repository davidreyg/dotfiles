# dotfiles

Configuración personal de Linux (y parcialmente macOS) gestionada con
[chezmoi](https://www.chezmoi.io/). Un comando deja una máquina nueva lista: Zsh con Zinit, Starship,
utilidades modernas, Git configurado y SSH a GitHub vía [rbw](https://github.com/doy/rbw).

![managed with chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)
![platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)
![shell](https://img.shields.io/badge/shell-zsh-89e051)

## Instalación

Requisitos: Debian/Ubuntu/Mint (o derivada), `curl`, `git`, `sudo` y una cuenta de Bitwarden con tu
clave SSH.

```bash
# 1. Dependencias mínimas
sudo apt-get update && sudo apt-get install -y curl git ca-certificates

# 2. chezmoi en ~/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
export PATH="$HOME/bin:$PATH"

# 3. Clonar y aplicar
chezmoi init --apply davidreyg/dotfiles
```

Al terminar, `exec zsh` para cargar el shell y los plugins.

Durante el `init` se pregunta el tipo de máquina (`personal`/`work`); el modo headless se detecta
solo. Después se instalan paquetes, binarios, fuentes y el shell.

> Para revisar antes de aplicar: `chezmoi init davidreyg/dotfiles`, `chezmoi diff` y
> `chezmoi apply --dry-run --verbose`.

### rbw (obligatorio para hacer push)

La clave SSH está en Bitwarden. Sin rbw desbloqueado no hay `git push`:

```bash
rbw register    # client_id + client_secret (Settings → Security → Keys)
rbw login       # contraseña maestra + 2FA
rbw unlock
ssh -T git@github.com
```

Guía detallada: [docs/secretos-y-ssh.md](docs/secretos-y-ssh.md).

## Qué incluye

- **Zsh + Zinit**: historial compartido, autosugerencias, resaltado, `fzf-tab`, `zsh-eza`.
- **Starship** con fuentes MesloLGS NF (solo en máquinas con GUI).
- **mise** para versiones de runtimes.
- **rbw + rbw-agent** como agente SSH.
- **Herramientas**: bat, eza, ripgrep, fd, fzf, btop, git-lfs.
- **Albert** como lanzador (solo escritorio Linux).
- **Fix de teclado Apple**: `fnmode=2` para que F1-F12 funcionen sin Fn.

## Documentación

La wiki vive en [`docs/`](docs/index.md):

| Documento | Contenido |
| --- | --- |
| [Instalación](docs/instalacion.md) | Guía completa paso a paso |
| [Arquitectura](docs/arquitectura.md) | Cómo funciona chezmoi aquí |
| [Configuración](docs/configuracion.md) | Perfiles, prompts y `[data]` |
| [Paquetes y externals](docs/paquetes-y-externals.md) | Qué se instala y cómo añadir más |
| [Secretos y SSH](docs/secretos-y-ssh.md) | rbw y GitHub |
| [Troubleshooting](docs/troubleshooting.md) | Problemas conocidos |
| [Roadmap](docs/roadmap.md) | Pendientes |
| [Agregar una feature](docs/agregar-feature.md) | Guía de extensión |

## Uso diario

| Comando | Para qué |
| --- | --- |
| `chezmoi status` / `chezmoi diff` | Ver deriva antes de aplicar |
| `chezmoi apply --dry-run --verbose` | Simular |
| `chezmoi apply` | Aplicar |
| `chezmoi update` | `git pull` + `apply` |
| `chezmoi edit ~/.zshrc` | Editar el origen, no el destino |
| `chezmoi cd` | Subshell en el repositorio |

No edites a mano archivos gestionados. Si lo hiciste, usa `chezmoi re-add <ruta>` y revisa el diff.

## Colaborar

El repositorio es personal, pero el flujo está pensado para trabajar con agentes y para escalar:

```bash
chezmoi cd
git pull

# editar en home/ o con chezmoi edit
chezmoi apply --dry-run --verbose
chezmoi apply

git add .
git commit -m "feat: ..."
git push
```

Antes de publicar:

```bash
chezmoi init                    # si cambió .chezmoi.toml.tmpl o [data]
chezmoi apply --dry-run --verbose
shellcheck /tmp/render.sh       # sobre los scripts renderizados
```

Convenciones:

- Commits en [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`,
  `refactor:`, `docs:`.
- Rama principal: `main`.
- Una funcionalidad nueva se documenta en `docs/features/` y se añade al índice.
- Para extender el repo paso a paso: [docs/agregar-feature.md](docs/agregar-feature.md).
- Skill disponible en [`skills/agregar-feature`](skills/agregar-feature/SKILL.md): muestra el plan,
  implementa, verifica y actualiza `AGENTS.md`, `README.md` y `docs/`.

## Estructura

```text
home/          # fuente de chezmoi (archivos, plantillas, scripts, externals)
docs/          # wiki modular
skills/        # skills para agentes
AGENTS.md      # instrucciones para agentes/IA
```

Detalle en [docs/arquitectura.md](docs/arquitectura.md).

## Plataformas

| Plataforma | Estado |
| --- | --- |
| Debian / Ubuntu / Mint / Pop!_OS / Zorin / Raspbian | Soportado (`apt`) |
| WSL | Soportado (headless) |
| macOS | Parcial (configuración y fuentes) |
| Contenedores / CI | Efímero (solo configuración) |

Probado con chezmoi `v2.73.3` en Linux Mint 22.x y Ubuntu 22.04.

---

Uso personal. El código se publica tal cual, sin garantías ni licencia explícita.
