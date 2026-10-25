# Teclado Apple / teclas F1-F12 (`fnmode`)

## Problema

Algunos teclados —Apple y varios de terceros mal detectados como Apple— priorizan las teclas
multimedia sobre F1-F12. En Linux eso hace que F1-F12 no respondan o actúen como volumen, brillo,
etc.

## Síntomas

- F1-F12 no hacen nada o lanzan funciones multimedia.
- `hwinfo --keyboard` muestra el dispositivo como "Apple Aluminium Keyboard (ANSI)" aunque no lo sea.
- El teclado funciona, pero las teclas de función no llegan a las aplicaciones.

## Diagnóstico

```bash
# Debian/Ubuntu
sudo apt-get install -y hwinfo

# Arch
sudo pacman -S hwinfo

hwinfo --keyboard
lsmod | grep -E 'hid_apple|mac_hid'
cat /sys/module/hid_apple/parameters/fnmode
```

Si `fnmode` vale `1` (o el módulo no está configurado), ese es el problema.

## Valores de `fnmode`

| Valor | Comportamiento |
| --- | --- |
| `0` | Desactivado: la tecla Fn no hace nada |
| `1` | Multimedia por defecto; Fn para F1-F12 |
| `2` | **F1-F12 por defecto; Fn para multimedia** (recomendado) |

## Solución en este repositorio

La gestiona el script:

```text
home/.chezmoiscripts/linux/run_onchange_before_16_fix_apple_fnkeys.sh.tmpl
```

### Cuándo se ejecuta

- Solo en Linux y `not is_headless`.
- Como es `run_onchange`, se ejecuta cuando cambia su contenido renderizado (por ejemplo, al
  actualizar el repo). El script comprueba el estado antes de tocar nada.

### Qué hace

1. Elige el módulo:
   - `hid_apple` si está cargado.
   - `mac_hid` si solo ese está cargado.
   - `hid_apple` por defecto si ninguno está cargado (teclado desconectado).
2. Comprueba si `/etc/modprobe.d/<módulo>.conf` ya contiene `options <módulo> fnmode=2`.
3. Si falta, escribe la línea y regenera el initramfs:
   - Debian/Ubuntu: `update-initramfs -u`.
   - Arch: `mkinitcpio -P`.
4. Si el módulo está cargado, escribe `2` en
   `/sys/module/<módulo>/parameters/fnmode` para aplicarlo en caliente.
5. Usa `sudo` solo si no se ejecuta como root.

### Resultado

```text
/etc/modprobe.d/hid_apple.conf
options hid_apple fnmode=2
```

## Aplicar el cambio

```bash
chezmoi apply
```

Si el script ya estaba aplicado y no hay cambios, no hace nada. Para forzar la reejecución:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Verificación

Sin reiniciar (el script aplica el valor en caliente si el módulo está cargado):

```bash
cat /sys/module/hid_apple/parameters/fnmode   # debe ser 2
```

Tras reiniciar, debe seguir en `2`. Para ver los eventos reales:

```bash
sudo apt-get install -y evtest
sudo evtest
# selecciona el teclado y pulsa F1-F12
```

También puedes comprobar en el escritorio con `xev` (X11) o `wev` (Wayland).

## Si el módulo es `mac_hid`

Algunos equipos usan `mac_hid` en lugar de `hid_apple`. El script lo detecta solo, pero si el módulo
no está cargado en el momento del apply, escribe `hid_apple` por defecto. En ese caso:

```bash
lsmod | grep mac_hid
echo "options mac_hid fnmode=2" | sudo tee /etc/modprobe.d/mac_hid.conf
sudo update-initramfs -u   # Debian/Ubuntu
sudo mkinitcpio -P         # Arch
sudo reboot
```

Luego, si quieres que chezmoi lo gestione, ajusta el script o fuerza la detección cargando el módulo
antes:

```bash
sudo modprobe hid_apple
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## El archivo `fnmode` no existe

El módulo no está cargado:

```bash
sudo modprobe hid_apple
lsmod | grep hid_apple
```

Si no existe el módulo, el teclado no usa el driver Apple y esta solución no aplica.

## Las teclas siguen sin funcionar

1. Revisa atajos del entorno (GNOME, KDE, Cosmic) en *Settings → Keyboard → Shortcuts*.
2. Comprueba si el teclado tiene **Fn Lock** físico o `Fn+Esc`.
3. Verifica con `evtest` si llegan los eventos.
4. Prueba en otra sesión (X11 vs Wayland).
5. Si nada funciona, es un problema del driver o del firmware del teclado, no de `fnmode`.

## Desactivar

1. Elimina el script `run_onchange_before_16_fix_apple_fnkeys.sh.tmpl`.
2. Borra la configuración y restaura el comportamiento por defecto:

   ```bash
   sudo rm -f /etc/modprobe.d/hid_apple.conf
   sudo update-initramfs -u
   sudo reboot
   ```

## Notas

- `fnmode` afecta a **todos** los teclados gestionados por `hid_apple` en la máquina.
- El script no instala paquetes; solo escribe configuración y regenera el initramfs.
- En servidores headless se omite a propósito.
- Si el teclado se conecta después del arranque y el módulo aún no estaba cargado, el `modprobe.d`
  igualmente se aplicará cuando se cargue.
