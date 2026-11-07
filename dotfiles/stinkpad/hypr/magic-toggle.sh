#!/bin/sh

# SUPER+R: hide focused window in special:magic; if something is hidden there, bring it back.

HIDDEN=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:magic") | .address')

if [ -n "$HIDDEN" ]; then
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
    for addr in $HIDDEN; do
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$CURRENT_WS\", follow = false, window = \"address:$addr\" })"
    done
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
else
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:magic\", follow = false })"
fi
