# Arquitectura

Este repositorio no es una colección de archivos copiados: es una **fuente de verdad declarativa**
que chezmoi renderiza según la máquina. Entender ese flujo evita el 90 % de los errores.

## Modelo de chezmoi

| Concepto | Valor en este repo |
| --- | --- |
| Repositorio git | `~/.local/share/chezmoi` (`github.com/davidreyg/dotfiles`, rama `main`) |
| Raíz de origen | `~/.local/share/chezmoi/home` (definida por `.chezmoiroot`) |
| Directorio destino | `$HOME` |
| Configuración generada | `~/.config/chezmoi/chezmoi.toml` |
| Estado de scripts | base de datos interna de chezmoi (se consulta con `chezmoi state`) |

`.chezmoiroot` contiene la palabra `home`. Por eso `README.md`, `docs/` y `skills/` viven en la raíz
del repositorio y **no** se gestionan: son documentación y herramientas, no archivos de usuario.

## Estructura

```text
.
├── .chezmoiroot                      # "home" -> raíz de origen
├── AGENTS.md                         # instrucciones para agentes/IA
├── README.md                         # instalación y colaboración (conciso)
├── docs/                             # esta wiki
│   ├── README.md                     # índice
│   ├── features/                     # una página por funcionalidad
│   └── plantillas/                   # plantilla para nuevas features
├── skills/
│   └── agregar-feature/SKILL.md      # skill para extender el repo
└── home/
    ├── .chezmoi.toml.tmpl            # configuración + [data]
    ├── .chezmoiexternal.toml.tmpl    # binarios y fuentes descargados
    ├── .chezmoiscripts/linux/        # scripts que corren fuera de ~
    ├── dot_zshrc.tmpl                # -> ~/.zshrc
    ├── dot_gitconfig.tmpl            # -> ~/.gitconfig
    └── dot_config/
        ├── starship.toml             # -> ~/.config/starship.toml
        ├── rbw/config.json           # -> ~/.config/rbw/config.json
        └── zsh/plugins.zsh           # -> ~/.config/zsh/plugins.zsh
```

## Convenciones de nombres

| Patrón | Significado | Ejemplo |
| --- | --- | --- |
| `dot_` | Se convierte en `.` al aplicar | `dot_zshrc.tmpl` → `~/.zshrc` |
| `.tmpl` | Plantilla Go, renderizada con `[data]` | `dot_gitconfig.tmpl` |
| `run_` | Script que se ejecuta en el destino | `run_after_20_install_starship.sh` |
| `run_onchange_` | Solo si cambia el contenido renderizado | `run_onchange_before_10_install-packages.sh.tmpl` |
| `run_once_` | Solo la primera vez en la máquina | (no se usa) |
| `before_` / `after_` | Orden respecto a la aplicación de archivos | `before_10`, `after_90` |
| `linux/` | Solo se ejecuta en Linux | `.chezmoiscripts/linux/` |
| `private_` | Permisos `0600` | (no se usa) |
| `executable_` | Permisos ejecutables | (no se usa) |

Los scripts se ordenan por nombre, por eso llevan prefijo numérico (`10`, `15`, `16`, `20`, `30`,
`90`). Deja huecos para insertar nuevos pasos sin renumerar.

## Fases de ejecución

```text
chezmoi init
  ├── clona/actualiza el repo
  ├── ejecuta home/.chezmoi.toml.tmpl
  └── guarda [data] en ~/.config/chezmoi/chezmoi.toml

chezmoi apply
  ├── run_before_*          (10 paquetes, 15 Albert, 16 teclado)
  ├── renderiza archivos gestionados
  └── run_after_*           (20 Starship, 30 mise, 90 chsh)
```

Puntos clave:

- **`init` y `apply` son cosas distintas.** `init` renderiza la configuración; `apply` escribe
  archivos y ejecuta scripts. `chezmoi update` = `git pull` + `apply`, **sin** `init`.
- **`run_onchange_` se basa en el hash del contenido renderizado.** Si añades un paquete a la lista o
  cambias cualquier texto que acabe en el script (incluidos comentarios de bash), el hash cambia y
  el script se vuelve a ejecutar. Un comentario de plantilla (`{{/* ... */}}`) no se renderiza, así
  que no altera el hash.
- **Los scripts no aparecen en `status` ni `diff`** porque la configuración generada los excluye:

  ```toml
  [status]
      exclude = ["scripts"]
  [diff]
      exclude = ["scripts"]
  ```

- Un script que renderiza vacío se ejecuta igual (sin efecto). Por eso los scripts usan
  `{{ if ... }}` alrededor de todo el contenido, incluido el shebang.

## El bloque `[data]` se calcula solo en `init`

`home/.chezmoi.toml.tmpl` es la única fuente de las variables que consumen el resto de plantillas.
Su salida se persiste:

```toml
[data]
    machine_type = "personal"
    is_headless = false
    is_ubuntu_like = true
    # ...
```

Consecuencias:

- `chezmoi apply` **no** recalcula `[data]`.
- Tras editar `.chezmoi.toml.tmpl` hay que ejecutar `chezmoi init`.
- Una máquina que hace `git pull` y recibe claves nuevas falla en las plantillas hasta que ejecute
  `chezmoi init`.
- Los valores quedan "congelados" en `~/.config/chezmoi/chezmoi.toml`; es intencional para que
  `apply` sea reproducible.

## Flujo de trabajo

```bash
chezmoi cd                 # subshell en el repositorio
git pull

chezmoi edit ~/.zshrc      # edita el ORIGEN, no el archivo de ~
chezmoi diff               # ver diferencias
chezmoi apply --dry-run --verbose
chezmoi apply

git add .
git commit -m "feat: ..."
git push                   # requiere rbw desbloqueado
```

Reglas:

- Nunca edites a mano un archivo gestionado (`~/.zshrc`, `~/.gitconfig`, …): genera deriva.
- Si ya lo hiciste, `chezmoi re-add <ruta>` copia el cambio a origen; después revisa el diff.
- Para archivos nuevos: `chezmoi add <ruta>`.
- Para dejar de gestionar: `chezmoi forget <ruta>`.

## Principios de diseño

1. **Idempotencia**: aplicar dos veces no debe cambiar nada. Los scripts comprueban el estado antes
   de actuar (`command -v`, `grep`, `systemctl`).
2. **Gating en plantillas, no en bash**: las condiciones de distro/headless viven en Go templates y
   producen scripts vacíos en lugar de ramas bash frágiles.
3. **Sin secretos en git**: las credenciales están en Bitwarden; el repo solo guarda configuración.
4. **Seguro en headless**: nada gráfico se instala si no hay GUI.
5. **Modularidad**: una funcionalidad nueva = un script/external + variables + página en `docs/`.

## Puntos de extensión

| Quiero… | Dónde | Guía |
| --- | --- | --- |
| Instalar un paquete apt | `run_onchange_before_10_install-packages.sh.tmpl` | [Paquetes](paquetes-y-externals.md) |
| Descargar un binario | `.chezmoiexternal.toml.tmpl` | [Paquetes](paquetes-y-externals.md) |
| Gestionar un archivo | `chezmoi add` o crear en `home/` | [Arquitectura](#flujo-de-trabajo) |
| Añadir una variable global | `.chezmoi.toml.tmpl` → `[data]` | [Configuración](configuracion.md) |
| Añadir un script | `.chezmoiscripts/linux/` | [Agregar feature](agregar-feature.md) |
| Documentar la feature | `docs/features/` + índice | [Plantilla](plantillas/nueva-feature.md) |
