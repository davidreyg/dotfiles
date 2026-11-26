---
layout: default
title: Remmina
parent: Funcionalidades
nav_order: 8
---

# Remmina

## Qué hace

Instala [Remmina](https://remmina.org/), un cliente gráfico de escritorio remoto, desde
[Flathub](https://flathub.org/apps/org.remmina.Remmina) mediante Flatpak.

## Estado

- Estable.
- Plataformas: Linux Ubuntu-like con escritorio.
- Instalación por usuario.

## Archivos implicados

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiscripts/linux/run_onchange_before_10_install-packages.sh.tmpl` | Instala Flatpak en escritorios Ubuntu-like. |
| `home/.chezmoiscripts/linux/run_onchange_before_17_install_remmina.sh.tmpl` | Configura Flathub e instala Remmina. |

## Variables y condiciones

No añade claves a `[data]`. Se ejecuta solo en Linux Ubuntu-like, no headless y no efímero.
Flatpak se instala únicamente en escritorios Ubuntu-like.

El remoto `flathub` y la aplicación se configuran en ámbito de usuario. Los servidores, las
distribuciones no Ubuntu-like y los entornos efímeros quedan excluidos.

## Instalación

Al ejecutar `chezmoi apply`:

1. El script de paquetes instala `flatpak` en una máquina apt-based Ubuntu-like con escritorio.
2. El script de Remmina crea el remoto Flathub para el usuario si aún no existe.
3. Instala `org.remmina.Remmina` para el usuario si todavía no está instalada.

Comandos equivalentes para instalación manual:

```bash
sudo apt-get update
sudo apt-get install -y flatpak
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user --noninteractive --assumeyes flathub org.remmina.Remmina
```

## Verificación

```bash
flatpak info --user org.remmina.Remmina
```

El comando debe mostrar los metadatos de Remmina instalada en el ámbito de usuario. También debe
aparecer en el menú de aplicaciones.

## Desactivar o eliminar

1. Elimina el bloque que añade `flatpak` al array de paquetes y el script
   `run_onchange_before_17_install_remmina.sh.tmpl`.
2. Ejecuta `chezmoi apply`.
3. Para quitar la aplicación:

   ```bash
   flatpak uninstall --user org.remmina.Remmina
   ```

4. Si ya no usas Flathub para ninguna otra aplicación, puedes quitar el remoto:

   ```bash
   flatpak remote-delete --user flathub
   ```

La eliminación de Flatpak del array no desinstala el paquete APT; quítalo manualmente solo si
ninguna otra aplicación lo necesita.

## Problemas conocidos

| Síntoma | Causa | Solución |
| --- | --- | --- |
| El script indica que falta Flatpak | La instalación APT no se completó antes de instalar Remmina | Revisa la salida de apt y vuelve a ejecutar `chezmoi apply`. |
| No aparece Remmina en el menú | El entorno no refrescó el menú o la instalación no terminó | Comprueba `flatpak info --user org.remmina.Remmina` y vuelve a iniciar sesión si hace falta. |

## Notas de diseño

- Se usa Flatpak porque Remmina se distribuye desde Flathub; no se instala el paquete APT de
  Remmina ni se descarga un binario como external.
- La instalación y el remoto son por usuario para evitar modificar la configuración de otros
  usuarios del sistema.
- El script es idempotente: conserva el remoto existente y no reinstala una aplicación ya instalada
  para ese usuario.
