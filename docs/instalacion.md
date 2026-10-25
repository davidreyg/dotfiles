# Instalación

Guía completa para dejar una máquina lista desde cero. Si solo quieres el camino corto, el
[README](../README.md) tiene la versión resumida.

## 1. Requisitos

- **Sistema**: Debian, Ubuntu, Linux Mint, Pop!_OS, Zorin o Raspbian (familia Debian/Ubuntu).
  macOS funciona de forma parcial (solo archivos de configuración y fuentes).
- **Acceso**: usuario con `sudo` y conexión a internet.
- **Cuenta**: Bitwarden con una clave SSH guardada como elemento de tipo *SSH key*.
- **Herramientas base**: `curl`, `git` y `ca-certificates`. El script de paquetes las instala, pero
  chezmoi las necesita **antes** de poder clonar el repositorio.

```bash
sudo apt-get update
sudo apt-get install -y curl git ca-certificates
```

## 2. Instalar chezmoi

El binario se instala en `~/bin`, que este repositorio añade al `PATH`:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
export PATH="$HOME/bin:$PATH"
chezmoi --version
```

> `~/.zshrc` añade `~/bin` al `PATH`, pero todavía no se ha aplicado. En una máquina limpia usa
> `export PATH` en la sesión actual (o `exec zsh` una vez aplicado).

Alternativas:

```bash
# macOS
brew install chezmoi

# Debian/Ubuntu con paquete oficial (versión puede ser más antigua)
sudo apt-get install -y chezmoi
```

## 3. Revisar antes de aplicar (recomendado)

```bash
chezmoi init davidreyg/dotfiles
chezmoi diff
chezmoi apply --dry-run --verbose
```

`chezmoi init` clona el repositorio en `~/.local/share/chezmoi` y calcula `[data]`. **No** modifica
todavía los archivos de tu `$HOME`.

## 4. Aplicar

```bash
chezmoi init --apply davidreyg/dotfiles
```

Durante la ejecución ocurre lo siguiente:

1. **Prompt de tipo de máquina** (`personal` o `work`). Solo aparece si hay TTY.
2. Pide la contraseña de `sudo` para instalar paquetes con `apt`.
3. Descarga binarios externos: `age`, `age-keygen`, `rbw`, `rbw-agent`, `eza`, `mise` y el repo de
   Zinit.
4. Instala Starship en `~/.local/bin`.
5. Instala Albert si la máquina no es headless.
6. Configura `fnmode=2` para teclados Apple/mal detectados (ver
   [teclado Apple](features/teclado-apple.md)).
7. Descarga las fuentes MesloLGS NF (solo con GUI).
8. Pregunta si quieres cambiar el shell por defecto a `/usr/bin/zsh` (solo con TTY).

> El modo headless se detecta automáticamente; no se pregunta. Detalles en
> [Configuración](configuracion.md#detección-de-headless).

### Instalación sin interacción

Sin TTY, el tipo de máquina cae en `personal` para que el aprovisionamiento continúe. Para forzar
valores:

```bash
chezmoi init --apply davidreyg/dotfiles \
  --promptChoice "Machine type=work"

# Forzar headless (por ejemplo, un servidor con X instalado)
CHEZMOI_HEADLESS=1 chezmoi init --apply davidreyg/dotfiles
```

## 5. Configurar rbw (obligatorio para hacer push)

La clave SSH que autoriza los pushes vive en Bitwarden. Sin rbw desbloqueado no podrás subir cambios
al repositorio.

```bash
rbw register    # client_id + client_secret de la API key
rbw login       # contraseña maestra + 2FA
rbw unlock      # arranca rbw-agent
ssh -T git@github.com
```

Salida esperada:

```text
Hi davidreyg! You've successfully authenticated, but GitHub does not provide shell access.
```

El procedimiento completo, con la ruta exacta a las API keys y la solución de problemas, está en
[Secretos y SSH](secretos-y-ssh.md).

## 6. Verificación

```bash
chezmoi status                  # sin diferencias
chezmoi doctor                  # sin errores críticos
echo "$SHELL"                   # /usr/bin/zsh
starship --version
eza --version
mise --version
rbw unlocked
ssh -T git@github.com
```

Cierra y abre la terminal (o `exec zsh`) para cargar plugins y el prompt.

## 7. Actualizar una máquina existente

```bash
chezmoi update        # git pull + apply
```

Si el repositorio introdujo claves nuevas en `[data]`, ejecuta antes:

```bash
chezmoi init
```

`chezmoi update` no recalcula `[data]`; solo `chezmoi init` lo hace. Ver
[Arquitectura](arquitectura.md#el-bloque-data-se-calcula-solo-en-init).

## 8. macOS

Se aplican `~/.zshrc`, `~/.gitconfig`, la configuración de Starship, rbw, y las fuentes. **No** hay
bootstrap de paquetes: instala Homebrew y las utilidades (`eza`, `bat`, `ripgrep`, `fd`, `fzf`,
`starship`) manualmente.

## 9. Desinstalar o reiniciar

```bash
# Ver qué archivos gestiona chezmoi
chezmoi managed

# Dejar de gestionar un archivo (no lo borra)
chezmoi forget ~/.config/foo

# Estado persistente de los scripts run_onchange
chezmoi state delete-bucket --bucket=scriptState
```

Para empezar de cero, borra `~/.local/share/chezmoi` y `~/.config/chezmoi` y repite esta guía. Haz
copia de tus claves SSH y de la configuración de rbw antes.
