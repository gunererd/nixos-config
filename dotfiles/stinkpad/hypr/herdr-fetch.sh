#!/usr/bin/env sh
# Bring the herdr-app window to the current workspace and focus it, or start it.
ws=$(hyprctl activeworkspace -j | jq -r '.id')
addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "herdr-app") | .address' | head -n1)
if [ -n "$addr" ]; then
  hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, silent = true, window = \"address:$addr\" })" >/dev/null
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
else
  uwsm-app -- herdr-app
fi
