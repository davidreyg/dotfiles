---
layout: default
title: Solución de problemas
nav_order: 7
---

# Troubleshooting

Diagnóstico general antes de tocar nada:

```bash
chezmoi doctor
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi data
```

## Tabla rápida

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `chezmoi: command not found` | `~/bin` no está en `PATH` | Abre una shell nueva o `exec zsh` |
| `map has no entry for key "..."` | `[data]` desactualizado | `chezmoi init` |
| `chezmoi apply` no cambia nada | Los scripts están excluidos de `diff` | Mira el hash del script / `scriptState` |
| El script de paquetes no corre | Su contenido renderizado no cambió | `chezmoi state delete-bucket --bucket=scriptState` |
| `chsh` omitido | Sin TTY o `zsh` fuera de `/etc/shells` | `chsh -s /usr/bin/zsh` |
| Primera shell lenta | Zinit clona plugins | Espera; las siguientes son rápidas |
| `eza` no descarga | Asset solo `x86_64` | Usa otro binario o elimina el external |
| `.local/bin/mise` aparece modificado | mise se autoactualiza | `chezmoi apply` lo realinea |
| F1-F12 hacen funciones multimedia | `fnmode` incorrecto | Ver [teclado Apple](features/teclado-apple.md) |
| `ssh -T git@github.com` falla | rbw bloqueado | Ver [Secretos y SSH](secretos-y-ssh.md) |

## Plantillas y `[data]`

### `map has no entry for key`

El repositorio añadió variables nuevas (`is_headless`, `is_ubuntu_like`, …) y tu
`~/.config/chezmoi/chezmoi.toml` no las tiene. `apply` no recalcula `[data]`:

```bash
chezmoi init
chezmoi data | grep -E "is_headless|machine_type"
```

### `chezmoi init` no pregunta el tipo de máquina

- No hay TTY (CI, pipe, `--no-tty`).
- Se pasó `--promptDefaults`.
- `machine_type` ya existe **y** se usó una variante `*Once` (no es el caso actual).

Comprueba con `tty` en la misma terminal. Para forzar:

```bash
chezmoi init --promptChoice "Machine type=work"
```

### La detección de headless es incorrecta

```bash
CHEZMOI_HEADLESS=1 chezmoi init   # forzar sin GUI
CHEZMOI_HEADLESS=0 chezmoi init   # forzar con GUI
```

## Scripts

### Ver qué se va a ejecutar

```bash
chezmoi apply --dry-run --verbose
```

### Reejecutar el script de paquetes

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Un script falla a mitad

Los scripts usan `set -eufo pipefail`, así que el primer error detiene la ejecución. Ejecuta el
renderizado para inspeccionarlo:

```bash
chezmoi execute-template < home/.chezmoiscripts/linux/run_onchange_before_10_install-packages.sh.tmpl > /tmp/pkg.sh
bash -n /tmp/pkg.sh
shellcheck /tmp/pkg.sh
```

### `apt` pide confirmación o falla por lock

- El script usa `-y`; si pide confirmación, hay otro proceso con el lock:

```bash
sudo lsof /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a
```

## Shell y prompt

### Zsh no es el shell por defecto

```bash
grep -qx /usr/bin/zsh /etc/shells && chsh -s /usr/bin/zsh
```

### No aparecen los iconos del prompt

Faltan las MesloLGS NF. Se instalan solo en máquinas no headless:

```bash
fc-list | grep -i meslo
```

Si no aparecen, revisa `is_headless` y vuelve a aplicar:

```bash
chezmoi apply --refresh-externals
```

### La primera shell tarda

Zinit descarga plugins y `starship init` se genera en el primer arranque. Es normal.

## rbw y SSH

Resumen; detalle en [Secretos y SSH](secretos-y-ssh.md).

```bash
rbw unlocked
echo "$SSH_AUTH_SOCK"
ssh-add -l
rbw stop-agent && rbw unlock
```

## Teclado

F1-F12, `fnmode`, `hid_apple` y `mac_hid`: [Teclado Apple](features/teclado-apple.md).

## Deriva de archivos

Si `chezmoi status` muestra `M` en un archivo que editaste a mano:

```bash
# Opción A: descartar el cambio local
chezmoi apply

# Opción B: conservar el cambio local en el origen
chezmoi re-add ~/.zshrc
chezmoi diff
```

Nunca edites los archivos renderizados directamente; usa `chezmoi edit`.

## Logs y depuración

```bash
chezmoi --verbose apply
chezmoi --debug apply
chezmoi doctor
```
