---
layout: default
title: Agregar una feature
nav_order: 9
---

# Agregar una funcionalidad

Guía operativa para extender el repositorio sin romper máquinas existentes. Está pensada para
humanos y para agentes; la skill [`skills/agregar-feature`](https://github.com/davidreyg/dotfiles/blob/main/skills/agregar-feature/SKILL.md)
automatiza este mismo flujo.

## 0. Decide el tipo de cambio

| Quieres… | Mecanismo | Dónde |
| --- | --- | --- |
| Instalar un paquete del sistema | Script `run_onchange_` con `apt` | `home/.chezmoiscripts/linux/` |
| Descargar un binario o una fuente | External | `home/.chezmoiexternal.toml.tmpl` |
| Gestionar un archivo de configuración | Archivo `dot_` o `chezmoi add` | `home/` |
| Ejecutar una configuración tras instalar | Script `run_after_` | `home/.chezmoiscripts/linux/` |
| Cambiar el comportamiento entre máquinas | Variable en `[data]` | `home/.chezmoi.toml.tmpl` |
| Corregir algo del sistema con root | Script `run_onchange_` | `home/.chezmoiscripts/linux/` |

Si el cambio mezcla varios, divídelo en commits pequeños.

## 1. Anuncia el plan

Antes de tocar archivos, escribe el plan con esta forma:

```text
Plan:
1. [investigar] Revisar el estado actual de X.
2. [implementar] Añadir el external/script/archivo Y.
3. [gating] Condicionar a is_headless / is_ubuntu_like.
4. [verificar] Render + shellcheck + dry-run.
5. [documentar] docs/features/Y.md, índice, AGENTS.md y README si aplica.
```

La skill muestra este plan al usuario y va marcando los pasos.

## 2. Investiga el estado actual

```bash
chezmoi status
chezmoi data
cat home/.chezmoi.toml.tmpl
ls home/.chezmoiscripts/linux/
```

Comprueba si ya existe algo parecido y si hay una entrada comentada en los externals.

## 3. Implementa

### Variable nueva en `[data]`

1. Añádela en la sección correspondiente de `home/.chezmoi.toml.tmpl`.
2. Documéntala en [Configuración](configuracion.md#variables-disponibles).
3. Recuerda: `[data]` solo se recalcula con `chezmoi init`.

Convenciones:

- Booleanos con prefijo `is_` (`is_headless`, `is_ubuntu_like`).
- Valores categóricos sin prefijo (`machine_type`).
- Comenta la sección y el consumidor.

### Script nuevo

- Nombre: `run_[once|onchange]_[before|after]_<NN>_<descripcion>.sh.tmpl`.
- Deja huecos numéricos (`16`, `20`, `30`).
- Primera línea del **resultado** debe ser `#!/bin/bash`; usa `{{- if ... -}}` para que, si no aplica,
  el archivo quede vacío.
- `set -eufo pipefail`.
- Idempotente: comprueba el estado antes de escribir (`command -v`, `grep -qxF`, `[ -e ]`).
- Root: usa una función `run_root` que omita `sudo` si `id -u` es 0.
- Evita `echo` con variables no controladas; usa `printf`.
- No imprimas secretos.

### External nuevo

- Usa `gitHubLatestReleaseAssetURL` para releases de GitHub.
- Añade `refreshPeriod` si no quieres consultar la API en cada apply.
- Añade `executable = true` para binarios.
- Verifica que exista asset para `linux-amd64` y, si no, limita el gate.

### Archivo gestionado nuevo

```bash
chezmoi add ~/.config/mi-herramienta/config.toml
chezmoi cd && git add . && git status
```

Si lleva valores por máquina, renómbralo a `.tmpl` y usa `{{ .variable }}`.

## 4. Gating correcto

| Situación | Condición |
| --- | --- |
| Solo Debian/Ubuntu con `apt` | `.is_apt_based` |
| Solo familia Ubuntu | `.is_ubuntu_like` |
| Nada gráfico en servidores | `not .is_headless` |
| Nada en contenedores/CI | `not .ephemeral` |
| Solo Linux | `eq .chezmoi.os "linux"` |

No compruebes la distro con `if [ -f /etc/debian_version ]` dentro de bash: renderiza el script vacío
desde Go.

## 5. Verifica

```bash
# Plantillas
chezmoi init
chezmoi data

# Render del script nuevo
chezmoi execute-template < home/.chezmoiscripts/linux/run_<...>.sh.tmpl > /tmp/feature.sh
bash -n /tmp/feature.sh
shellcheck /tmp/feature.sh

# Casos negativos (headless / no apt) con una config temporal
chezmoi --config /tmp/headless.toml execute-template < home/.chezmoiscripts/linux/run_<...>.sh.tmpl | wc -c

# Estado global
chezmoi status
chezmoi apply --dry-run --verbose
```

Criterios de aceptación:

- [ ] `chezmoi init` no falla.
- [ ] El script renderiza `0 bytes` cuando no aplica.
- [ ] `shellcheck` limpio.
- [ ] `apply --dry-run` sin errores.
- [ ] Aplicar dos veces no cambia nada (idempotencia).
- [ ] `chezmoi status` limpio salvo deriva esperada.

## 6. Documenta

Siempre:

1. Crea `docs/features/<nombre>.md` desde la [plantilla](plantillas/nueva-feature.md).
2. Añade el front matter: `layout: default`, `title`, `parent: Funcionalidades` y `nav_order`.
3. Añade la fila en la tabla de [`docs/features/index.md`](features/index.md) y en el
   [índice](index.md).
4. Actualiza `AGENTS.md` (layout, comportamiento, gotchas).
5. Actualiza esta guía si el flujo cambia.

Si el cambio afecta al uso diario o a la instalación:

6. Actualiza el `README.md` (conciso, con enlace a la página de la feature).
7. Actualiza [`roadmap.md`](roadmap.md) (marca el ítem o añade el nuevo).

## 7. Commit

Conventional Commits:

```bash
git add .
git commit -m "feat: add <feature>"
git push        # requiere rbw desbloqueado
```

Prefijos usados: `feat:`, `fix:`, `refactor:`, `docs:`.

## 8. Rollback

- External/paquete: elimina la entrada y aplica; los archivos ya descargados se quedan hasta que los
  borres a mano.
- Script: elimínalo; el estado de `run_onchange` queda en la base de chezmoi (puedes limpiarlo con
  `chezmoi state delete-bucket --bucket=scriptState`).
- Archivo gestionado: `chezmoi forget <ruta>` deja de gestionarlo sin borrarlo.

## Uso de la skill

```text
/skill agregar-feature
```

La skill carga este flujo, muestra el plan, implementa, verifica y actualiza la documentación. Si no
está registrada en tu cliente, el archivo está en
[`skills/agregar-feature/SKILL.md`](https://github.com/davidreyg/dotfiles/blob/main/skills/agregar-feature/SKILL.md).
