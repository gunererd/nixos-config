#!/usr/bin/env sh
# Pull every window onto the currently focused workspace. Recovery for when a
# lid-close/dock shuffle scatters windows across workspaces/monitors.
# Hyprland 0.55+ parses `hyprctl dispatch` as Lua, so use the hl.dsp form.
ws=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl -j clients | jq -r '.[].address' | while read -r addr; do
  hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, silent = true, window = \"address:$addr\" })" >/dev/null
done
