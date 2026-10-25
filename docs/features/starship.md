---
layout: default
title: Starship
parent: Funcionalidades
nav_order: 2
---

# Starship

## Qué hace

Prompt minimalista, rápido y con glifos de Nerd Font. Se instala en `~/.local/bin` y Zinit lo
inicializa de forma diferida.

## Archivos

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiscripts/linux/run_after_20_install_starship.sh` | Instala el binario si falta |
| `home/dot_config/starship.toml` | Configuración del prompt |
| `home/dot_config/zsh/plugins.zsh` | Inicialización diferida |
| Externals | Fuentes MesloLGS NF |

## Instalación

```bash
#!/bin/bash
mkdir -p ~/.local/bin
if [ ! -f ~/.local/bin/starship ]; then
    curl -sS https://starship.rs/install.sh | sh -s -y -b ~/.local/bin
fi
```

- Corre en cada `apply`, pero no reinstala si el binario existe.
- No usa externals porque necesita el instalador oficial.

## Inicialización en Zsh

```bash
zinit ice has"starship" id-as"starship-init" nocompile \
    atclone"starship init zsh > init.zsh; starship completions zsh > _starship" \
    atpull"%atclone" src"init.zsh"
zinit light zdharma-continuum/null
```

Genera el script una vez y lo reutiliza; no ejecuta `starship init` en cada arranque.

## Configuración

`~/.config/starship.toml` define módulos, colores y formato. Es un archivo estático (sin plantilla):
las diferencias entre máquinas no se aplican aquí.

> El archivo contiene glifos Nerd Font y finales de línea LF. No lo reescribas con herramientas de
> Windows; preserva bytes.

## Fuentes

Solo se descargan si `not ephemeral` y `not is_headless`:

- MesloLGS NF Regular / Bold / Italic / Bold Italic
- Destino Linux: `~/.local/share/fonts`
- Destino macOS: `~/Library/Fonts`

Verifica:

```bash
fc-list | grep -i "MesloLGS NF"
```

## Verificación

```bash
starship --version
exec zsh
# El prompt debe mostrar usuario, ruta, rama git, etc.
```

## Actualizar

```bash
curl -sS https://starship.rs/install.sh | sh -s -y -b ~/.local/bin
```

El script de chezmoi no actualiza un binario existente.

## Desactivar

1. Comenta el bloque de inicialización en `plugins.zsh`.
2. Opcional: elimina `~/.config/starship.toml`.
3. `chezmoi apply`.

## Problemas conocidos

| Síntoma | Solución |
| --- | --- |
| Cuadrados en el prompt | Instala las fuentes y configura la terminal para usarlas |
| Prompt lento | Revisa módulos costosos en `starship.toml`; usa `starship timings` |
| `starship: command not found` | `chezmoi apply` y `exec zsh` (el PATH incluye `~/.local/bin`) |
