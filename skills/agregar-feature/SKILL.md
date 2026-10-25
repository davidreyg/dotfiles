---
name: agregar-feature
description: Añade una funcionalidad a este repositorio de dotfiles (chezmoi) mostrando el plan, implementándola con gating por [data], verificándola y actualizando AGENTS.md, README.md y la wiki en docs/. Úsala cuando el usuario pida una feature nueva, un paquete, un external, un script o un archivo gestionado.
---

# Agregar una feature a los dotfiles

Trabajas en un repositorio de dotfiles gestionado por **chezmoi**. Sigue este flujo completo. No
empieces a escribir archivos sin haber anunciado el plan.

## Regla de oro

Antes de tocar nada, muestra al usuario un plan con esta forma (adaptado al caso):

```text
Plan:
1. [investigar] Revisar el estado actual de <X>.
2. [implementar] <external | script | archivo | variable>.
3. [gating] Condicionar a is_headless / is_apt_based / is_ubuntu_like / ephemeral.
4. [verificar] Render, shellcheck, casos negativos y dry-run.
5. [documentar] docs/features/<x>.md, índice, AGENTS.md y README si aplica.
6. [commit] feat: ... (solo si el usuario lo pide).
```

Ve marcando cada paso (`[x]`) a medida que avanzas y reporta al final qué se hizo y qué no.

## 1. Investigar

```bash
chezmoi status
chezmoi data
cat home/.chezmoi.toml.tmpl
cat home/.chezmoiexternal.toml.tmpl
ls -1 home/.chezmoiscripts/linux/
git log --oneline -10
```

Comprueba si ya existe una feature parecida o una entrada comentada.

## 2. Elegir el mecanismo

| Necesidad | Mecanismo | Destino |
| --- | --- | --- |
| Paquete del sistema | Script `run_onchange_` con `apt` | `home/.chezmoiscripts/linux/` |
| Binario o fuente | External | `home/.chezmoiexternal.toml.tmpl` |
| Archivo de configuración | `dot_` o `chezmoi add` | `home/` |
| Configuración post-instalación | Script `run_after_` | `home/.chezmoiscripts/linux/` |
| Diferencia entre máquinas | Variable `[data]` | `home/.chezmoi.toml.tmpl` |
| Cambio con root | Script `run_onchange_` | `home/.chezmoiscripts/linux/` |

## 3. Implementar

Reglas obligatorias:

- **Gating en Go template**, no con `if [ -f /etc/debian_version ]` en bash. Si no aplica, el script
  debe renderizar vacío (0 bytes).
- El shebang debe quedar en la **primera línea** del resultado: usa `{{- if ... -}}` al inicio.
- `set -eufo pipefail`.
- Idempotencia: `command -v`, `grep -qxF`, `[ -e ]`, `systemctl is-enabled`, etc.
- Root: función `run_root` que omita `sudo` si `id -u` es 0.
- No escribas secretos en el repo.
- Scripts nuevos: `run_[once|onchange]_[before|after]_<NN>_<nombre>.sh.tmpl`, con huecos numéricos.
- Variables nuevas: booleanos `is_*`, documentadas en `docs/configuracion.md`.

## 4. Verificar

```bash
chezmoi init
chezmoi execute-template < <script> > /tmp/feature.sh
bash -n /tmp/feature.sh
shellcheck /tmp/feature.sh

# Caso negativo: renderizar con otra config
chezmoi --config /tmp/headless.toml execute-template < <script> | wc -c   # esperado: 0

chezmoi status
chezmoi apply --dry-run --verbose
```

Criterios:

- [ ] `chezmoi init` sin errores.
- [ ] Script vacío cuando no aplica.
- [ ] `shellcheck` limpio.
- [ ] `apply --dry-run` correcto.
- [ ] Idempotente (aplicar dos veces no cambia nada).

## 5. Documentar (obligatorio)

Actualiza, en este orden:

1. **`docs/features/<nombre>.md`** desde `docs/plantillas/nueva-feature.md`:
   qué hace, archivos, variables, verificación, desactivación, problemas y notas.
2. **`docs/features/<nombre>.md`**: añade el front matter (`layout`, `title`,
   `parent: Funcionalidades`, `nav_order`) y la fila en `docs/features/index.md` y en `docs/index.md`.
3. **`AGENTS.md`**:
   - layout si hay archivos nuevos;
   - comportamiento si cambia `[data]` o un gate;
   - gotchas si hay una trampa nueva.
4. **`README.md`** solo si afecta a la instalación o al uso diario; debe seguir siendo conciso.
5. **`docs/roadmap.md`**: marca el ítem como hecho o añade el nuevo pendiente.
6. **`docs/arquitectura.md`** / `docs/paquetes-y-externals.md` si cambia el flujo general.

Enlaces relativos y comandos copiables. No documentes como existente algo que está en el roadmap.

## 6. Commit

Solo si el usuario lo pide. Convención:

```bash
git add .
git commit -m "feat: <descripción>"
```

## Salida final

Resume:

- Qué se implementó y dónde.
- Qué se verificó (comandos y resultados).
- Qué documentación se actualizó.
- Qué queda pendiente o requiere decisión del usuario.
- Si hay que ejecutar `chezmoi init` en otras máquinas (por variables nuevas).
