#!/usr/bin/env bash
# Volume control script with notifications

case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
esac

# Get current volume and mute status
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | grep -o '[0-9]*%' | head -n 1 | sed 's/%//')
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

# Use actual volume for display (no capping)
DISPLAY_VOLUME=$VOLUME

# Send notification with timeout
if [ "$MUTE" = "yes" ]; then
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume -h int:value:$DISPLAY_VOLUME "Volume (Muted)" "${DISPLAY_VOLUME}%"
else
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume -h int:value:$DISPLAY_VOLUME "Volume" "${DISPLAY_VOLUME}%"
fi