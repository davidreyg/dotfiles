---
layout: default
title: Inicio
nav_order: 1
description: Índice de la wiki técnica del repositorio de dotfiles gestionado con chezmoi.
---

# Documentación

Wiki técnica de este repositorio de dotfiles. Está pensada para uso personal, pero escrita para que
cualquier persona (o agente) pueda entender cómo funciona el repositorio, replicarlo y extenderlo sin
leer todos los archivos primero.

La documentación es **modular**: cada funcionalidad tiene su propia página en
[`features/`](features/) y existe una [plantilla](plantillas/nueva-feature.md) para añadir nuevas.

## Índice

| Documento | Qué encontrarás |
| --- | --- |
| [Instalación](instalacion.md) | Requisitos, instalación paso a paso, primer `apply`, verificación. |
| [Arquitectura](arquitectura.md) | Cómo funciona chezmoi aquí, estructura del repo, fases de ejecución. |
| [Configuración y perfiles](configuracion.md) | Variables de `[data]`, prompts, detección de headless y efímeros. |
| [Paquetes y externals](paquetes-y-externals.md) | Qué instala cada script, binarios descargados y cómo añadir más. |
| [Secretos y SSH](secretos-y-ssh.md) | rbw, Bitwarden, agente SSH y verificación con GitHub. |
| [Solución de problemas](troubleshooting.md) | Diagnóstico y solución de problemas conocidos. |
| [Roadmap](roadmap.md) | Pendientes con su motivación y notas de implementación. |
| [Agregar una feature](agregar-feature.md) | Guía paso a paso para extender el repositorio. |

### Funcionalidades

| Página | Estado | Resumen |
| --- | --- | --- |
| [Zsh + Zinit](features/zsh.md) | Estable | Historial, autosugerencias, resaltado, completados y plugins. |
| [Starship](features/starship.md) | Estable | Prompt instalado y cargado de forma diferida. |
| [mise](features/mise.md) | Estable | Gestor de runtimes con autocompletado. |
| [Albert](features/albert.md) | Estable | Lanzador gráfico desde el repo oficial de openSUSE. |
| [rbw](features/rbw.md) | Estable | Bitwarden + agente SSH. |
| [Teclado Apple / Fn](features/teclado-apple.md) | Estable | `fnmode=2` para que F1-F12 funcionen sin Fn. |

## Cómo se publica

La documentación se publica con **GitHub Pages** y el tema
[Just the Docs](https://just-the-docs.com/), servido desde la carpeta `docs/` del repositorio.

- La configuración del sitio está en [`_config.yml`](_config.yml).
- El tema se declara con `remote_theme`; GitHub Pages lo descarga en cada despliegue, sin instalar
  nada en local.
- `baseurl: /dotfiles` porque es un *project site* (`davidreyg.github.io/dotfiles`). Si cambias el
  nombre del repositorio o usas un dominio propio, actualiza también esa línea.
- Los enlaces entre páginas se escriben con `.md` (funcionan al navegar el repo en GitHub). En el
  sitio publicado, el plugin `jekyll-relative-links` los convierte a la URL final.

Pasos para activarlo (una sola vez):

1. Settings → Pages.
2. Source: *Deploy from a branch*.
3. Branch `main`, carpeta `/docs`.
4. Guardar. La portada será [`index.md`](index.md).

### Front matter obligatorio

Jekyll solo procesa los archivos que empiezan con un bloque YAML entre `---`. Sin ese bloque, la
página se copia tal cual, **no aparece en el menú lateral** y los enlaces `.md` no se reescriben.

```yaml
---
layout: default
title: Instalación
nav_order: 2
---
```

Reglas del menú:

| Elemento | Claves necesarias |
| --- | --- |
| Página normal | `layout`, `title`, `nav_order` |
| Categoría (padre) | `layout`, `title`, `nav_order`, `has_children: true` |
| Subpágina (hija) | `layout`, `title`, `parent: <título exacto del padre>`, `nav_order` |
| Página oculta | `layout`, `title`, `nav_exclude: true` |

El valor de `parent` debe coincidir **exactamente** con el `title` del padre. Ejemplo real: la
categoría [Funcionalidades](features/) usa `has_children: true` y cada página de `features/` declara
`parent: Funcionalidades`.

### Previsualizar en local (opcional)

```bash
gem install bundler jekyll
cd docs
jekyll serve --baseurl ""
```

Sin `baseurl` local, el sitio se sirve en `http://localhost:4000`. En GitHub Pages se usa
`baseurl: /dotfiles`.

## Convenciones de esta documentación

- **Una funcionalidad = una página** en `features/`, con las mismas secciones: qué hace, archivos,
  variables, verificación, desactivación y notas.
- **Front matter en todas las páginas**, con `title` y `nav_order`; las categorías añaden
  `has_children` y las hijas `parent`.
- **Enlaces relativos con `.md`** entre documentos, para que funcionen en el repo y en Pages.
- **Ejemplos ejecutables**: todo comando debe poder copiarse tal cual.
- **Estado real**: si algo está en el roadmap, no se documenta como si existiera.
- Al añadir o cambiar una funcionalidad, actualiza: la página de la feature, este índice,
  [`AGENTS.md`](https://github.com/davidreyg/dotfiles/blob/main/AGENTS.md) y, si afecta al uso
  diario, el [`README.md`](https://github.com/davidreyg/dotfiles/blob/main/README.md).
