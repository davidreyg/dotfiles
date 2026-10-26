---
layout: default
title: Configuración
nav_order: 4
render_with_liquid: false
---

# Configuración y perfiles

Todo lo que cambia entre máquinas se decide en `home/.chezmoi.toml.tmpl` y se expone como `[data]`.
Las plantillas y scripts **nunca** inspeccionan el hostname por su cuenta.

## Estructura del archivo

El template está dividido en nueve secciones comentadas:

1. **Defaults** — todas las variables empiezan en `false` o vacías.
2. **Identidad del SO** — construye `osid`.
3. **Familia de distro** — `is_ubuntu_like` e `is_apt_based`.
4. **Entornos efímeros** — detecta CI, contenedores, Codespaces y usuarios desechables.
5. **Hostname** — workaround de macOS con `scutil`.
6. **Tipo de máquina** — el único prompt interactivo.
7. **Headless** — detección automática.
8. **Valores derivados** — email.
9. **Salida** — el bloque `[data]`.

## Variables disponibles

| Variable | Tipo | Valores | Consumidores |
| --- | --- | --- | --- |
| `machine_type` | string | `personal`, `work`, `ephemeral` | Documentación, decisiones futuras |
| `personal` | bool | `machine_type == "personal"` | Reservado para secretos personales |
| `work` | bool | `machine_type == "work"` | Reservado para configuración laboral |
| `is_headless` | bool | detectado / forzado | `xclip`, fuentes, Albert, fnkeys |
| `ephemeral` | bool | detectado | externals, scripts de GUI, `chsh` |
| `is_ubuntu_like` | bool | Ubuntu y derivadas | externals, `btop`, Albert |
| `is_apt_based` | bool | Ubuntu + Debian + Raspbian | script de paquetes `apt` |
| `osid` | string | `linux-linuxmint`, `darwin`, … | Diagnóstico y gating |
| `hostname` | string | hostname efectivo | Diagnóstico |
| `email` | string | correo | `[data]` (el `.gitconfig` lo tiene fijo) |

> `personal` y `work` hoy no cambian el contenido aplicado; existen para que futuras features (por
> ejemplo, correo o claves distintas) no tengan que volver a tocar la detección.

## Tipo de máquina

- **Con TTY**: `chezmoi init` ejecuta `promptChoice` con `personal` (por defecto) y `work`.
- **Sin TTY**: se asume `personal` para que el aprovisionamiento no se detenga.
- **Efímero**: no se pregunta; `machine_type = "ephemeral"`.

Se usa `promptChoice` (no `promptChoiceOnce`) a propósito. Las variantes `*Once` reutilizan el valor
que ya exista en `[data]`, por lo que un valor viejo puede saltarse la pregunta sin avisar. Ese fue
un bug real en este repositorio.

### Forzar sin interacción

```bash
chezmoi init --promptChoice "Machine type=work"
```

Con `--promptDefaults` las funciones de prompt devuelven su valor por defecto sin preguntar.

## Detección de headless

```gotemplate
{{- $headlessOverride := env "CHEZMOI_HEADLESS" -}}
{{- if ne $headlessOverride "" -}}
{{-   $headless = or (eq $headlessOverride "1") (eq $headlessOverride "true") -}}
{{- else if $ephemeral -}}
{{-   $headless = true -}}
{{- else if eq .chezmoi.os "linux" -}}
{{-   $defaultTarget := output "sh" "-c" "command -v systemctl >/dev/null 2>&1 && systemctl get-default 2>/dev/null || true" | trim -}}
{{-   $headless = not (or (eq $defaultTarget "graphical.target") (ne (env "DISPLAY") "") (ne (env "WAYLAND_DISPLAY") "")) -}}
{{- end -}}
```

Orden de decisión:

1. `CHEZMOI_HEADLESS=1` o `0` fuerza el valor.
2. Efímero → `true`.
3. Linux → `false` si el arranque es `graphical.target` **o** hay `DISPLAY`/`WAYLAND_DISPLAY`.
4. macOS → `false` (se asume GUI).

Se usa `systemctl get-default` porque `DISPLAY` no existe al entrar por SSH a un escritorio; el target
sigue siendo `graphical.target`.

### Forzar headless

```bash
CHEZMOI_HEADLESS=1 chezmoi init
CHEZMOI_HEADLESS=0 chezmoi init
```

Casos típicos: un Mac mini administrado por SSH (`=1`) o un servidor con X instalado pero sin sesión
gráfica (`=1`). También sirve para probar el flujo headless en un escritorio.

## Entornos efímeros

Se marcan como `ephemeral = true`:

- Variables de entorno: `CODESPACES`, `REMOTE_CONTAINERS_IPC`, `CI`.
- Usuarios: `root`, `ubuntu`, `vagrant`, `vscode`.
- Contenedores Docker (`/.dockerenv`) o Podman (`/run/.containerenv`).
- Windows nativo.

Efectos: no descarga externals, no instala fuentes, no cambia el shell y fuerza headless.

## Detección de distro

```gotemplate
{{- $ubuntuLike := eq $osID "linux-ubuntu" -}}
{{- if and (eq .chezmoi.os "linux") (hasKey .chezmoi.osRelease "idLike") -}}
{{-   $ubuntuLike = or $ubuntuLike (contains "ubuntu" .chezmoi.osRelease.idLike) -}}
{{- end -}}
```

- `is_ubuntu_like`: `osid == linux-ubuntu` **o** `ID_LIKE` contiene `ubuntu`. Cubre Mint, Pop!_OS,
  Zorin, elementary y derivadas no listadas.
- `is_apt_based`: además incluye `ID` `debian`/`raspbian` y `ID_LIKE` con `debian`.

`hasKey` protege macOS, donde `.chezmoi.osRelease` está vacío y `missingkey=error` haría fallar el
render.

## Email

Hoy hay una sola dirección. Si el portátil de trabajo necesita otra, el punto de cambio es:

```gotemplate
{{- $email := "neisserrey@upeu.edu.pe" -}}
{{- if $work -}}
{{-   $email = "otra@ejemplo.com" -}}
{{- end -}}
```

`home/dot_gitconfig.tmpl` tiene el correo fijo; si quieres que use la variable, cámbialo a
`email = {{ .email }}`.

## Inspeccionar y depurar

```bash
chezmoi data                                  # JSON con [data] y .chezmoi
chezmoi execute-template '{{ .is_headless }}' # renderizar una expresión
chezmoi cat ~/.zshrc                          # ver el archivo renderizado
chezmoi execute-template < home/.chezmoiscripts/linux/run_onchange_before_10_install-packages.sh.tmpl
```

## Cambiar valores

1. Edita `home/.chezmoi.toml.tmpl`.
2. Ejecuta `chezmoi init` (imprescindible).
3. Verifica con `chezmoi data`.
4. Aplica con `chezmoi apply`.

Recuerda: `apply` no recalcula `[data]`; si solo aplicas, seguirás viendo los valores viejos.
