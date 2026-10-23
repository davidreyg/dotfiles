#!/bin/bash

# Verificar que el binario de mise existe
MISE_BIN="$HOME/.local/bin/mise"

if [ -x "$MISE_BIN" ]; then
    echo "Configurando autocompletados para mise..."
    # --install coloca el _mise en ~/.local/share/zsh/site-functions
    "$MISE_BIN" completion zsh --install
fi