#!/usr/bin/env bash
# Brightness control script with notifications

case "$1" in
    up)
        brightnessctl set +5%
        ;;
    down)
        brightnessctl set 5%-
        ;;
esac

# Get current brightness percentage
BRIGHTNESS=$(brightnessctl get)
MAX_BRIGHTNESS=$(brightnessctl max)
PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Send notification with timeout
notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness -h int:value:$PERCENTAGE "Brightness" "${PERCENTAGE}%"