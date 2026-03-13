#!/bin/bash

LOCATION=""
LANG="es"
URL="wttr.in/${LOCATION}?format=%t+%C&lang=${LANG}"

weather=$(curl -s --max-time 20 "$URL")

if [ $? -eq 0 ] && [ -n "$weather" ]; then
    echo "$weather"
else
    echo "Weather Error!"
fi
