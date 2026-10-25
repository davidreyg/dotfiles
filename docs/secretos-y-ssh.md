# Secretos y SSH

El repositorio **no contiene secretos**. Las credenciales viven en Bitwarden y se sirven bajo demanda
con [rbw](https://github.com/doy/rbw). La clave SSH que autoriza los pushes a GitHub también está en
Bitwarden.

## Por qué rbw y no el CLI oficial

`bw` exige la contraseña maestra en cada operación y no expone un agente SSH. `rbw`:

- Guarda una base local cifrada que se desbloquea una vez.
- Se registra con la **API key** (no con la contraseña), evitando la detección de bots de Bitwarden.
- Incluye `rbw-agent`, que habla el protocolo de `ssh-agent`.
- Es un binario único, sin Node.js.

## Instalación

La instalan los externals en `~/.local/bin`:

- `rbw`
- `rbw-agent`
- autocompletado `_rbw`

La configuración está en `~/.config/rbw/config.json` (solo correo y preferencias, sin secretos).

## Registro

1. Abre el vault web → **Settings → Security → Keys → View API key**.
2. Copia `client_id` (empieza por `user.`) y `client_secret`.
3. Ejecuta:

```bash
rbw register
```

Introduce el correo si lo pide, el `client_id` y el `client_secret`. No uses la contraseña maestra
aquí.

## Login y desbloqueo

```bash
rbw login     # contraseña maestra + 2FA
rbw unlock    # descifra la base y arranca rbw-agent
```

`rbw unlock` debe repetirse tras cada reinicio o tras `rbw lock`.

## Agente SSH

`~/.zshrc` exporta el socket:

```bash
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
```

`rbw-agent` sirve las claves de Bitwarden a través de ese socket. La clave debe estar guardada como
elemento de tipo **SSH key** (no como nota ni login).

## Verificación

```bash
echo "$SSH_AUTH_SOCK"     # .../rbw/ssh-agent-socket
rbw unlocked              # exit 0 si está desbloqueado
ssh-add -l                # lista la clave
ssh -T git@github.com
```

Salida esperada:

```text
Hi davidreyg! You've successfully authenticated, but GitHub does not provide shell access.
```

Prueba de escritura real:

```bash
chezmoi cd
git pull
```

## Problemas frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `Permission denied (publickey)` | Agente bloqueado o clave ausente | `rbw unlock`, revisa `ssh-add -l` |
| `The agent has no identities` | La clave no es de tipo SSH key o el agente no corre | Corrige el elemento en Bitwarden, `rbw stop-agent && rbw unlock` |
| `SSH_AUTH_SOCK` vacío | Shell sin `XDG_RUNTIME_DIR` o sin recargar | `exec zsh`, revisa `~/.zshrc` |
| rbw pide la contraseña raro en servidor | `pinentry` gráfico no disponible | `rbw config set pinentry pinentry-tty` |
| `rbw register` falla | API key mal copiada | Regenera la API key en el vault |
| Datos desactualizados | Base local vieja | `rbw sync` |

## Seguridad

- La contraseña maestra nunca se guarda en el repo ni en la configuración.
- El socket del agente vive en `$XDG_RUNTIME_DIR` (permisos del usuario, se borra al cerrar sesión).
- `lock_timeout` y `sync_interval` están en 3600 s en `~/.config/rbw/config.json`.
- Si el repositorio pasara a privado, el clonado inicial necesitaría un token; los pushes seguirían
  usando SSH.

## Pendiente

El desbloqueo automático al iniciar sesión con una unidad de usuario de systemd está en el
[roadmap](roadmap.md).
