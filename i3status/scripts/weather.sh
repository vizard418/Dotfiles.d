#!/bin/bash

LOCATION=""
LANG="es"
URL="wttr.in/${LOCATION}?format=%l:+%t+%C&lang=${LANG}"
FILE="$HOME/.config/i3status/logs/weather.txt"

# Crear el directorio si no existe
mkdir -p "$(dirname "$FILE")"

weather=$(curl -s --max-time 10 "$URL" | sed 's/  */ /g')

if [ $? -eq 0 ] && [ -n "$weather" ]; then
    echo "$weather" > "$FILE"
else
    echo "Weather Connection Error!" > "$FILE"
fi

