---
layout: default
title: Funcionalidades
nav_order: 10
has_children: true
description: Una página por funcionalidad del repositorio, con su instalación, verificación y desactivación.
---

# Funcionalidades

Cada funcionalidad del repositorio tiene su propia página con la misma estructura: qué hace, archivos
implicados, variables y condiciones, verificación, desactivación y notas de diseño.

| Página | Estado | Resumen |
| --- | --- | --- |
| [Zsh + Zinit](zsh.md) | Estable | Historial, autosugerencias, resaltado, completados y plugins. |
| [Starship](starship.md) | Estable | Prompt instalado y cargado de forma diferida. |
| [mise](mise.md) | Estable | Gestor de runtimes con autocompletado. |
| [Albert](albert.md) | Estable | Lanzador gráfico desde el repo oficial de openSUSE. |
| [rbw](rbw.md) | Estable | Bitwarden + agente SSH. |
| [Teclado Apple / Fn](teclado-apple.md) | Estable | `fnmode=2` para que F1-F12 funcionen sin Fn. |

Para añadir una página nueva:

1. Copia [`plantillas/nueva-feature.md`](../plantillas/nueva-feature.md).
2. Añade el front matter con `layout`, `title`, `parent: Funcionalidades` y `nav_order`.
3. Añade la fila en la tabla anterior y en el [índice](../index.md).
