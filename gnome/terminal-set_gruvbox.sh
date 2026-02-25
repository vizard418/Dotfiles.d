#!/bin/bash

# Obtener el ID del perfil default de GNOME Terminal
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
PATH_PREFIX="/org/gnome/terminal/legacy/profiles:/:$PROFILE"

# Aplicar colores Gruvbox
dconf write "$PATH_PREFIX/background-color" "'#282828'"
dconf write "$PATH_PREFIX/foreground-color" "'#ebdbb2'"
dconf write "$PATH_PREFIX/use-theme-colors" "false"
dconf write "$PATH_PREFIX/palette" "['#282828', '#cc241d', '#98971a', '#d79921', '#458588', '#b16286', '#689d6a', '#ebdbb2', '#3c3836', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#fbf1c7']"

echo "Configuracion de colores Gruvbox aplicada a $PROFILE"
