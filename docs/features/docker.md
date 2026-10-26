---
layout: default
title: Docker Engine + Compose
parent: Funcionalidades
nav_order: 7
render_with_liquid: false
---

# Docker Engine + Compose

## Qué hace

Instala **Docker Engine** (`docker-ce`) y el plugin **Compose v2** desde el repositorio oficial de
Docker, configura el acceso sin `sudo` para el usuario y deja el servicio habilitado al arranque.

## Estado

- **Estable.**
- Plataformas: Linux con `apt` (Ubuntu, Linux Mint, Pop!_OS, Zorin, elementary, Debian, Raspbian).
- Se instala también en máquinas **headless**: Docker es útil en servidores.
- No se instala en entornos **efímeros** (CI, contenedores, Codespaces).
- Compose se usa como plugin: `docker compose` (no el antiguo `docker-compose` v1).

## Archivos implicados

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiscripts/linux/run_onchange_before_12_install_docker.sh.tmpl` | Repositorio, paquetes, grupo y servicio |

No hay binarios externos ni archivos de configuración gestionados: todo lo hace `apt` y los
paquetes oficiales.

## Variables y condiciones

```gotemplate
{{- if and (eq .chezmoi.os "linux") (not .ephemeral) .is_apt_based -}}
```

| Variable | Efecto |
| --- | --- |
| `is_apt_based` | Requisito. Sin `apt` (macOS, Fedora, Arch) el script renderiza vacío. |
| `ephemeral` | Si es `true`, no se instala nada. |
| `is_headless` | **No** se usa: Docker también se instala en servidores. |

No se añadieron variables nuevas a `[data]`, así que otras máquinas no necesitan `chezmoi init`:
basta con `chezmoi apply`.

## Instalación

El script corre **después** de los paquetes base (paso 10) y antes de Albert (paso 15), porque
necesita `curl` y `apt`.

1. Si `docker` y `docker compose` ya funcionan, sale sin cambios.
2. Detecta la distribución:
   - Ubuntu y derivadas → repositorio `ubuntu`. Para Mint usa `UBUNTU_CODENAME` (Mint 22.x →
     `noble`), no el codename de Mint (`zena`), que Docker no publica.
   - Debian/Raspbian → repositorio `debian`.
   - Otra distribución → mensaje y salida limpia (`exit 0`).
3. Descarga la clave GPG en `/etc/apt/keyrings/docker.asc`.
4. Escribe `/etc/apt/sources.list.d/docker.list` solo si el contenido cambió.
5. Ejecuta `apt-get update` e instala:

   ```text
   docker-ce  docker-ce-cli  containerd.io  docker-buildx-plugin  docker-compose-plugin
   ```

6. Agrega el usuario al grupo `docker` si aún no pertenece.
7. Si systemd es PID 1, ejecuta `systemctl enable --now docker`. En WSL sin systemd se omite.

### Equivalentes manuales

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

## Verificación

```bash
docker --version
docker compose version
systemctl is-active docker
docker info --format '{{.ServerVersion}}'
```

Prueba real:

```bash
docker run --rm hello-world
```

Si acabas de aplicar y aún no puedes usar Docker sin `sudo`, abre una sesión nueva o ejecuta:

```bash
newgrp docker
```

## Configuración

| Ruta | Contenido |
| --- | --- |
| `/etc/apt/keyrings/docker.asc` | Clave GPG del repositorio |
| `/etc/apt/sources.list.d/docker.list` | Repositorio `stable` |
| `/etc/docker/daemon.json` | Configuración del daemon (**no gestionada** por chezmoi) |
| `/var/lib/docker` | Imágenes, contenedores y volúmenes |

`daemon.json` se deja sin gestionar a propósito: proxies, registries o límites de logs cambian según
la red de cada máquina. Si lo necesitas:

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
```

Después: `sudo systemctl restart docker`.

## Desactivar o eliminar

1. Elimina `home/.chezmoiscripts/linux/run_onchange_before_12_install_docker.sh.tmpl`.
2. `chezmoi apply` (ya no se ejecutará en el futuro).
3. Desinstala los paquetes y limpia el repositorio:

   ```bash
   sudo apt-get remove -y docker-ce docker-ce-cli containerd.io \
     docker-buildx-plugin docker-compose-plugin
   sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc
   sudo apt-get update
   ```

4. Opcional: borra datos e imágenes (irreversible):

   ```bash
   sudo rm -rf /var/lib/docker /var/lib/containerd
   ```

5. Quita el usuario del grupo:

   ```bash
   sudo gpasswd -d "$USER" docker
   ```

## Problemas conocidos

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `permission denied ... /var/run/docker.sock` | La sesión es anterior a `usermod` | `newgrp docker` o cerrar sesión |
| `docker compose` no existe | Solo hay Compose v1 (`docker-compose`) | Instala `docker-compose-plugin` con `chezmoi apply` |
| `docker.io` instalado | Paquete de la distro en conflicto | `sudo apt-get remove -y docker.io docker-compose` y reaplicar |
| El repo da 404 | Codename no publicado por Docker | Revisa `UBUNTU_CODENAME`; actualiza la distro |
| Servicio no arranca en WSL | WSL sin systemd | Activa systemd en `/etc/wsl.conf` o `sudo service docker start` |
| Los puertos ignoran `ufw` | Docker inserta reglas propias en iptables | Publica en `127.0.0.1` o usa `ufw-docker` |

## Notas de diseño

- **Repositorio oficial y no `docker.io`**: `docker.io` de Ubuntu/Debian va por detrás y no incluye
  el plugin Compose v2.
- **`run_onchange`**: el script solo se reevalúa cuando cambia su contenido renderizado; además
  comprueba el estado para no repetir trabajo.
- **Grupo `docker` = privilegios de root.** Es cómodo para uso personal, pero cualquier proceso del
  usuario puede montar el sistema de archivos del host. La alternativa es
  [rootless mode](https://docs.docker.com/engine/security/rootless/), pendiente en el
  [roadmap](../roadmap.md).
- **Sin gate de headless**: a diferencia de Albert o las fuentes, Docker no necesita GUI.
- **No se gestiona `daemon.json`** para no imponer una configuración de red global.

## Referencias

- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Docker Compose plugin](https://docs.docker.com/compose/install/linux/)
- [Rootless mode](https://docs.docker.com/engine/security/rootless/)
