# Zsh + Zinit

## Qué hace

Define el shell interactivo: historial compartido, completado, plugins y el orden de carga de todo lo
demás (Starship, mise, rbw).

## Archivos

| Archivo | Destino | Rol |
| --- | --- | --- |
| `home/dot_zshrc.tmpl` | `~/.zshrc` | Configuración base y variables de entorno |
| `home/dot_config/zsh/plugins.zsh` | `~/.config/zsh/plugins.zsh` | Plugins de Zinit y completados |

## `~/.zshrc`

### Historial

```bash
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000
setopt append_history share_history hist_ignore_space hist_ignore_all_dups
setopt hist_save_no_dups hist_ignore_dups hist_find_no_dups HIST_REDUCE_BLANKS
```

- `share_history`: las sesiones abiertas comparten historial.
- `hist_ignore_space`: un comando precedido por espacio no se guarda.
- Se eliminan duplicados consecutivos y globales.

### Completado

```bash
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'l:|=* r:|=*' 'r:|=* l:|=*'
```

Completado insensible a mayúsculas, por prefijo, sufijo y en cualquier posición.

### `PATH`

Se añaden, si existen:

1. `~/bin`
2. `~/.local/bin`
3. `~/.opencode/bin`

`~/bin` es donde se instala chezmoi; `~/.local/bin` recibe los externals.

### mise

```bash
fpath=($HOME/.local/share/zsh/site-functions $fpath)
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi
```

### rbw

```bash
if [[ -n ${XDG_RUNTIME_DIR:-} ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
fi
```

Solo se define si existe `XDG_RUNTIME_DIR` (sesiones gráficas y SSH con systemd).

### Carga de plugins

```bash
[[ -f "${HOME}/.config/zsh/plugins.zsh" ]] && source "${HOME}/.config/zsh/plugins.zsh"
```

## `~/.config/zsh/plugins.zsh`

### Zinit

```bash
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
```

Zinit se descarga como external (`~/.local/share/zinit/zinit.git`).

### Plugins cargados

| Plugin | Función |
| --- | --- |
| `fast-syntax-highlighting` | Resaltado de sintaxis en la línea de comandos |
| `zsh-completions` | Completados adicionales |
| `zsh-autosuggestions` | Sugerencias basadas en historial |
| `fzf-tab` | Completado con `fzf` |
| `zsh-you-should-use` | Recuerda aliases existentes |
| `zsh-eza` | Integración de `eza` (reemplazo de `ls`) |
| OMZ `git`, `key-bindings`, `colored-man-pages`, `docker` | Snippets de Oh My Zsh |
| `_docker`, `_eza`, `_chezmoi`, `_starship` | Completados |

### Carga diferida

La mayoría usa `wait` o `lucid` para no bloquear el arranque. Starship y el completado de chezmoi se
generan con `atclone`/`atpull` y se cargan como `zdharma-continuum/null`.

### `compinit`

```bash
zicompinit
zicdreplay
```

El `compinit` global de `/etc/zsh/zshrc` corre antes de este archivo y no ve los completados que
Zinit instala después, por eso se reinicia al final.

## Verificación

```bash
exec zsh
echo $ZINIT_HOME
which eza starship mise
zinit list | head
```

## Añadir un plugin

1. Añade una línea en `home/dot_config/zsh/plugins.zsh`:

   ```bash
   zinit light owner/repo
   ```

2. Si es un completado:

   ```bash
   zinit ice as"completion" lucid wait"0"
   zinit snippet https://.../_comando
   ```

3. `chezmoi apply` y abre una shell nueva.

## Primer arranque lento

Zinit clona todos los plugins y genera `init.zsh` de Starship. Es esperado; las siguientes sesiones
son rápidas.

## Desactivar

Elimina la línea del plugin en `plugins.zsh` y aplica. Para desactivar todo Zinit, comenta el `source`
de `plugins.zsh` en `.zshrc`; perderás autosugerencias, resaltado y completados.
