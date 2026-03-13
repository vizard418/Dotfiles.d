#!/bin/bash

LOCATION=""
LANG="es"
URL="wttr.in/${LOCATION}?format=%l:+%t+%C&lang=${LANG}"
FILE="$HOME/.cache/i3status/weather-info"

# Crear el directorio si no existe
mkdir -p "$(dirname "$FILE")"

weather=$(curl -s --max-time 20 "$URL" | sed 's/  */ /g')

if [ $? -eq 0 ] && [ -n "$weather" ]; then
    echo "$weather" > "$FILE"
else
    echo "Weather Connection Error!" > "$FILE"
fi

