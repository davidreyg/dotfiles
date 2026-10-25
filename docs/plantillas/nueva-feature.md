---
layout: default
title: Plantilla de feature
nav_exclude: true
---

# <Nombre de la funcionalidad>

> Copia este archivo a `docs/features/<nombre>.md`, rellena las secciones y añádelo al
> [índice de funcionalidades](../features/index.md). Borra esta cita.
>
> El front matter debe quedar así (el `title` es el que verás en el menú lateral):
>
> ```yaml
> ---
> layout: default
> title: <Nombre corto>
> parent: Funcionalidades
> nav_order: 7
> ---
> ```

## Qué hace

Una o dos frases: qué problema resuelve y para quién.

## Estado

- Estable / experimental / pendiente.
- Plataformas: Linux / macOS / WSL.
- Desde: commit o fecha.

## Archivos implicados

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiexternal.toml.tmpl` | Descarga del binario |
| `home/.chezmoiscripts/linux/run_after_XX_<nombre>.sh` | Configuración posterior |
| `home/dot_config/...` | Configuración gestionada |

## Variables y condiciones

| Variable | Efecto |
| --- | --- |
| `is_headless` | … |
| `is_ubuntu_like` | … |

¿Se puede desactivar? ¿Cómo?

## Instalación

Pasos concretos que ejecuta chezmoi, en orden.

```bash
# comandos manuales equivalentes, si existen
```

## Verificación

```bash
# comandos que demuestran que funciona
```

Resultado esperado.

## Configuración

Rutas, variables de entorno, archivos de configuración y valores por defecto.

## Desactivar o eliminar

1. Qué entrada borrar.
2. Qué script eliminar.
3. Cómo limpiar restos (`~/.local/bin/...`, estado de chezmoi, etc.).

## Problemas conocidos

| Síntoma | Causa | Solución |
| --- | --- | --- |
| … | … | … |

## Notas de diseño

Decisiones no obvias: por qué un external y no un paquete, por qué un gate concreto, qué se probó y
qué no.

## Referencias

- Documentación oficial.
- Issues o discusiones relevantes.
