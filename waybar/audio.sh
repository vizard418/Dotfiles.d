#!/bin/bash

# 1. Obtener el puerto activo actual
CURRENT_PORT=$(pactl list sinks | grep "Active Port" | awk '{print $3}')

# 2. Obtener los dos puertos analogicos disponibles (filtrando el actual)
# Esto busca cualquier puerto que empiece con 'analog-output-'
NEXT_PORT=$(pactl list sinks | grep -oP 'analog-output-[\w-]+(?=:)' | grep -v "$CURRENT_PORT" | head -n1)

# 3. Si por alguna razon NEXT_PORT esta vacio, no hacer nada para evitar errores
if [ -z "$NEXT_PORT" ]; then
    exit 1
fi

# 4. Cambiar al siguiente puerto
pactl set-sink-port @DEFAULT_SINK@ "$NEXT_PORT"
