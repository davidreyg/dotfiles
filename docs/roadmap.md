# Roadmap

Pendientes ordenados por impacto. Cada uno incluye la motivación y una pista de implementación para
que se pueda retomar sin contexto.

## Instalación de aplicaciones

- [ ] **Brave Browser**
  - Motivación: navegador principal en una máquina nueva.
  - Implementación: repositorio APT oficial con clave firmada, o snap. Añadir al script de paquetes
    solo en `not is_headless`.
  - Verificación: `brave-browser --version`.

- [ ] **OpenCode**
  - Motivación: `~/.zshrc` ya añade `~/.opencode/bin` al `PATH`, pero el binario no se instala.
  - Implementación: script `run_after_*` con el instalador oficial, idempotente (`command -v`).
  - Verificación: `opencode --version`.

- [ ] **Visual Studio Code**
  - Motivación: editor principal.
  - Implementación: repo APT de Microsoft con clave firmada; alternativa snap `--classic`.
  - Verificación: `code --version`.

## Operación

- [ ] **Desbloqueo automático de rbw**
  - Motivación: `rbw unlock` se pierde en cada reinicio; el primer push falla.
  - Implementación: unidad de usuario `rbw-agent.service` con `systemd`, o `pam_exec` bien acotado.
  - Cuidado: no guardar la contraseña maestra en texto plano.

- [ ] **Backup y recuperación de secretos**
  - Motivación: la clave SSH y el vault son un punto único de fallo.
  - Implementación: documentar exportación del vault y recuperación de la clave SSH.

## Plataformas

- [ ] **Soporte macOS completo**
  - Motivación: hoy solo se aplican archivos y fuentes.
  - Implementación: bootstrap con Homebrew, `chsh` equivalente y paquetes (`eza`, `bat`, `fzf`, …).

- [ ] **Detección de teclado Apple más fina**
  - Motivación: `fnmode=2` se aplica a cualquier Linux no headless.
  - Implementación: condicionar el script a la presencia de `hid_apple`/`mac_hid` o a un USB vendor
    ID, y documentar cómo desactivarlo.

## Calidad

- [ ] **CI de validación**
  - Motivación: detectar plantillas rotas antes de aplicar.
  - Implementación: GitHub Actions con `chezmoi init --apply` en un contenedor y `shellcheck` sobre
    los scripts renderizados.

- [ ] **Documentación publicada**
  - Motivación: la wiki ya está en `docs/`.
  - Implementación: activar GitHub Pages desde la carpeta `/docs` (o sincronizar la wiki).

- [ ] **Plantilla de feature aplicada por la skill**
  - Motivación: que `skills/agregar-feature` genere automáticamente la página en `docs/features/`.
  - Implementación: añadir un esqueleto copiable y referenciarlo desde la skill. (Ya existe la
    [plantilla](plantillas/nueva-feature.md); falta el copiado automático.)

## Cómo proponer algo

1. Describe el problema y el resultado esperado.
2. Indica en qué sección del repo encaja (paquete, external, script, archivo gestionado).
3. Añade la página en `docs/features/` cuando esté implementado.
4. Actualiza este roadmap al cerrar el ítem.
