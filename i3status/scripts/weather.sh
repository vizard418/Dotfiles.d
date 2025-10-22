#!/bin/bash

LOCATION=""
LANG="es"
URL="wttr.in/${LOCATION}?format=%l:+%t+%C&lang=${LANG}"
FILE="$HOME/.config/i3status/logs/weather.txt"

# Crear el directorio si no existe
mkdir -p "$(dirname "$FILE")"

attempt=0
max_attempts=2
success=0

while [ $attempt -lt $max_attempts ]; do
    weather=$(curl -s --max-time 10 "$URL" | sed 's/  */ /g')
    if [ $? -eq 0 ] && [ -n "$weather" ]; then
        echo "$weather" > "$FILE"
        success=1
        break
    fi
    attempt=$((attempt+1))
done

if [ $success -eq 0 ]; then
    echo "Weather Connection Error" > "$FILE"
fi

