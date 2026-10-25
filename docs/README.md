# Documentación

Wiki técnica de este repositorio de dotfiles. Está pensada para uso personal, pero escrita para que
cualquier persona (o agente) pueda entender cómo funciona el repositorio, replicarlo y extenderlo sin
leer todos los archivos primero.

La documentación es **modular**: cada funcionalidad tiene su propia página en [`features/`](features/)
y existe una [plantilla](plantillas/nueva-feature.md) para añadir nuevas.

## Índice

| Documento | Qué encontrarás |
| --- | --- |
| [Instalación](instalacion.md) | Requisitos, instalación paso a paso, primer `apply`, verificación. |
| [Arquitectura](arquitectura.md) | Cómo funciona chezmoi aquí, estructura del repo, fases de ejecución. |
| [Configuración y perfiles](configuracion.md) | Variables de `[data]`, prompts, detección de headless y efímeros. |
| [Paquetes y externals](paquetes-y-externals.md) | Qué instala cada script, binarios descargados y cómo añadir más. |
| [Secretos y SSH](secretos-y-ssh.md) | rbw, Bitwarden, agente SSH y verificación con GitHub. |
| [Troubleshooting](troubleshooting.md) | Diagnóstico y solución de problemas conocidos. |
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

El contenido vive en `docs/` dentro del repositorio principal, así que GitHub ya lo renderiza.

**GitHub Pages (recomendado):**

1. Settings → Pages.
2. Source: *Deploy from a branch*.
3. Branch `main`, carpeta `/docs`.
4. Guardar. La portada será este `README.md`.

**GitHub Wiki (opcional):**

```bash
git clone https://github.com/davidreyg/dotfiles.wiki.git
cp docs/*.md docs/features/*.md docs/plantillas/*.md dotfiles.wiki/
cd dotfiles.wiki && git add . && git commit -m "docs: sync wiki" && git push
```

> La wiki no conserva la estructura de carpetas de la misma forma y los enlaces relativos con `.md`
> pueden necesitar ajustes. Si se publica en la wiki, conviene enlazar por nombre de página.

## Convenciones de esta documentación

- **Una funcionalidad = una página** en `features/`, con las mismas secciones: qué hace, archivos,
  variables, verificación, desactivación y notas.
- **Enlaces relativos** entre documentos, para que funcionen en el repo y en Pages.
- **Ejemplos ejecutables**: todo comando debe poder copiarse tal cual.
- **Estado real**: si algo está en el roadmap, no se documenta como si existiera.
- Al añadir o cambiar una funcionalidad, actualiza: la página de la feature, este índice,
  [`../AGENTS.md`](../AGENTS.md) y, si afecta al uso diario, el [`../README.md`](../README.md).
