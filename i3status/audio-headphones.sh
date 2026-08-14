#!/bin/bash
pactl set-sink-port @DEFAULT_SINK@ analog-output-headphones
echo "HEADPHONES" > ~/.cache/i3status/audio-dev
killall -SIGUSR1 i3status
