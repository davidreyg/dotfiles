---
layout: default
title: mise
parent: Funcionalidades
nav_order: 3
---

# mise

## Qué hace

Gestiona versiones de runtimes (Node, Python, Go, …) por proyecto mediante `.mise.toml`, sin depender
de los paquetes del sistema.

## Archivos

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiexternal.toml.tmpl` | Descarga el binario |
| `home/.zshrc.tmpl` | Activa mise y añade el `fpath` |
| `home/.chezmoiscripts/linux/run_after_30_setup_mise.sh` | Genera el autocompletado |

## Instalación

El external consulta la última release de `jdx/mise` y descarga el asset:

```gotemplate
{{- $miseVersion := (gitHubLatestRelease "jdx/mise").TagName }}
{{- $os := .chezmoi.os }}
{{- $arch := .chezmoi.arch }}
{{- if eq $arch "amd64" }}{{ $arch = "x64" }}{{ end }}

[".local/bin/mise"]
    type = "archive-file"
    url = "https://github.com/jdx/mise/releases/download/{{ $miseVersion }}/mise-{{ $miseVersion }}-{{ $os }}-{{ $arch }}.tar.gz"
    executable = true
    path = "mise/bin/mise"
    refreshPeriod = "168h"
```

- `refreshPeriod = 168h`: chezmoi vuelve a consultar la release cada semana.
- El asset de GitHub usa `x64`, no `amd64`; por eso se normaliza.
- Gate: `is_ubuntu_like` y `not ephemeral`.

## Activación

En `~/.zshrc`:

```bash
fpath=($HOME/.local/share/zsh/site-functions $fpath)
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi
```

El `fpath` se añade antes para que el completado generado por el script esté disponible.

## Autocompletado

`run_after_30_setup_mise.sh`:

```bash
MISE_BIN="$HOME/.local/bin/mise"
if [ -x "$MISE_BIN" ]; then
    "$MISE_BIN" completion zsh --install
fi
```

Escribe `_mise` en `~/.local/share/zsh/site-functions`.

## Uso

```bash
mise use --global node@22
mise use python@3.12
mise install
mise ls
```

En un proyecto, crea `.mise.toml` y versiona ese archivo, no el binario.

## Verificación

```bash
mise --version
mise doctor
which node
```

## Deriva conocida

`chezmoi status` puede mostrar `M .local/bin/mise` porque mise se autoactualiza y difiere del asset
descargado. `chezmoi apply` lo realinea con la release fijada en el external. Si prefieres evitar el
vaivén, desactiva la autoactualización:

```bash
mise settings set auto_install false   # ajusta según tu versión
```

O elimina el `refreshPeriod` para que no se actualice en cada apply.

## Desactivar

1. Elimina el bloque de `mise` en `.chezmoiexternal.toml.tmpl`.
2. Elimina la activación de `.zshrc`.
3. Elimina `run_after_30_setup_mise.sh`.
4. `chezmoi apply`.
