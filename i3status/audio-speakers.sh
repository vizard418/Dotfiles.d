#!/bin/bash
pactl set-sink-port @DEFAULT_SINK@ analog-output-lineout
echo "SPEAKERS" > ~/.cache/i3status/audio-dev
killall -SIGUSR1 i3status
