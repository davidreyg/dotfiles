#!/bin/bash
# Descargar e instalar Starship en ~/.local/bin
mkdir -p ~/.local/bin
if [ ! -f ~/.local/bin/starship ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
fi