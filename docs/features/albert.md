---
layout: default
title: Albert
parent: Funcionalidades
nav_order: 4
render_with_liquid: false
---

# Albert

## Qué hace

Instala [Albert](https://albertlauncher.github.io/), un lanzador gráfico tipo Spotlight, desde el
repositorio oficial de openSUSE Build Service (OBS).

## Archivos

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiscripts/linux/run_onchange_before_15_install_albert.sh.tmpl` | Instalación |

## Condiciones

```gotemplate
{{- if and (eq .chezmoi.os "linux") (not .is_headless) -}}
```

- Solo Linux.
- Solo máquinas con GUI: en servidores no tiene sentido y no se instala.
- Es idempotente: si `albert` ya está en el `PATH`, sale con `exit 0`.

## Cómo instala

### Ubuntu y derivadas

Detecta el codename de Ubuntu (`noble`, `jammy`, `focal`) y elige el repositorio OBS:

```text
xUbuntu_24.04   (noble)
xUbuntu_22.04   (jammy)
xUbuntu_20.04   (focal)
xUbuntu_<versionID>  (fallback)
```

Luego:

1. Descarga `Release.key` y la importa en `/etc/apt/trusted.gpg.d/`.
2. Añade el repo en `/etc/apt/sources.list.d/`.
3. `apt-get update && apt-get install -y albert`.

### Debian

Usa `Debian_<versionID>` con el mismo procedimiento.

### RHEL / CentOS / Alma / Rocky

Añade el repo `CentOS_9_Stream`, instala `epel-release` y luego `albert` con `dnf`.

## Verificación

```bash
command -v albert
albert --version
```

En el escritorio, el lanzador debe aparecer en el menú de aplicaciones. Si no, cierra sesión y vuelve
a entrar.

## Desinstalar

1. Elimina el script `run_onchange_before_15_install_albert.sh.tmpl`.
2. Elimina el repositorio y la clave añadidos:

   ```bash
   sudo rm -f /etc/apt/sources.list.d/home:manuelschneid3r.list
   sudo rm -f /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg
   sudo apt-get remove -y albert
   ```

3. `chezmoi apply`.

## Notas de diseño

- Se usa un script y no un external porque Albert se distribuye como paquete del sistema y necesita
  dependencias gráficas (Qt).
- La comprobación `command -v` evita reinstalar en cada `apply` (aunque `run_onchange` ya limita la
  frecuencia).
- Si el repo de OBS cambia de nombre o de ruta, hay que actualizar las tres ramas del script.

## Problemas conocidos

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `apt` no encuentra `albert` | Repo OBS mal añadido o codename no soportado | Revisa `/etc/apt/sources.list.d/` y el codename |
| No arranca en Wayland | Limitación de Qt/entorno | Prueba en X11 o revisa la documentación de Albert |
| Se instaló en un servidor | `is_headless` mal detectado | `CHEZMOI_HEADLESS=1 chezmoi init` y elimina el paquete |
