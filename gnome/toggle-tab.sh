GNOME_SETTING="org.gnome.shell.window-switcher current-workspace-only"
current_value=$(gsettings get $GNOME_SETTING)

if [ "$current_value" = "true" ]; then
    gsettings set $GNOME_SETTING false
    echo "Conmutador de ventanas: TODAS las ventanas."
else
    gsettings set $GNOME_SETTING true
    echo "Conmutador de ventanas: ESPACIO DE TRABAJO ACTUAL."
fi

exit 0
