---
layout: default
title: rbw
parent: Funcionalidades
nav_order: 5
---

# rbw

## Qué hace

Cliente no oficial de Bitwarden en Rust. Sustituye a `bw` para dos tareas:

1. Servir contraseñas y códigos TOTP desde una base local cifrada.
2. Exponer las claves SSH de Bitwarden mediante un agente compatible con `ssh-agent`.

Es la pieza que permite hacer `git push` sin gestionar claves SSH en disco.

## Archivos

| Archivo | Rol |
| --- | --- |
| `home/.chezmoiexternal.toml.tmpl` | Descarga `rbw`, `rbw-agent` y el completado |
| `home/dot_config/rbw/config.json` | Configuración (correo, timeouts, pinentry) |
| `home/dot_zshrc.tmpl` | Exporta `SSH_AUTH_SOCK` |

## Binarios

| Destino | Origen |
| --- | --- |
| `~/.local/bin/rbw` | release de `doy/rbw` |
| `~/.local/bin/rbw-agent` | release de `doy/rbw` |
| `~/.local/share/zsh/site-functions/_rbw` | completado de Zsh |

Gate: `is_ubuntu_like` y `not ephemeral`.

## Configuración

`~/.config/rbw/config.json`:

```json
{
    "email": "davidreygu@gmail.com",
    "base_url": null,
    "identity_url": null,
    "notifications_url": null,
    "lock_timeout": 3600,
    "sync_interval": 3600,
    "pinentry": "pinentry",
    "client_cert_path": null
}
```

- `lock_timeout`: segundos antes de bloquearse solo.
- `sync_interval`: cada cuánto sincroniza con el servidor.
- `pinentry`: en servidores sin GUI, usar `pinentry-tty`:

  ```bash
  rbw config set pinentry pinentry-tty
  ```

No contiene secretos.

## Flujo

```bash
rbw register    # una vez por máquina: client_id + client_secret
rbw login       # contraseña maestra + 2FA
rbw unlock      # descifra y arranca rbw-agent
```

Guía completa en [Secretos y SSH](../secretos-y-ssh.md).

## Agente SSH

`~/.zshrc`:

```bash
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
```

`rbw-agent` sirve las claves de Bitwarden. La clave debe estar guardada como elemento de tipo
**SSH key**.

## Verificación

```bash
rbw --version
rbw unlocked
ssh-add -l
ssh -T git@github.com
```

## Comandos útiles

| Comando | Uso |
| --- | --- |
| `rbw ls` | Listar entradas |
| `rbw get <nombre>` | Obtener contraseña |
| `rbw code <nombre>` | Código TOTP |
| `rbw sync` | Sincronizar la base |
| `rbw lock` | Bloquear |
| `rbw stop-agent` | Detener el agente |
| `rbw purge` | Borrar la base local |

## Desactivar

1. Elimina las entradas de rbw en `.chezmoiexternal.toml.tmpl`.
2. Elimina `home/dot_config/rbw/config.json`.
3. Elimina el `export SSH_AUTH_SOCK` de `.zshrc`.
4. `chezmoi apply`.

Los binarios en `~/.local/bin` se quedan hasta que los borres a mano.

## Notas

- No hay secretos en el repositorio; el vault es la fuente de verdad.
- Si el agente queda en mal estado: `rbw stop-agent && rbw unlock`.
- El desbloqueo automático al iniciar sesión está en el [roadmap](../roadmap.md).
