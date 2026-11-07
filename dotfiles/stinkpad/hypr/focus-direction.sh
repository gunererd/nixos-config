#!/bin/bash
# Directional focus that includes floating windows (Hyprland's movefocus skips them from tiled).
# Usage: focus_direction.sh l|r|u|d
# ponytail: nearest-center heuristic (distance + 2x perpendicular offset), not edge-aware.

dir=$1
active=$(hyprctl activewindow -j)
ws=$(hyprctl activeworkspace -j | jq -r .id)

target=$(hyprctl clients -j | jq -r --argjson a "${active:-null}" --arg ws "$ws" --arg dir "$dir" '
  def center: {x: (.at[0] + .size[0] / 2), y: (.at[1] + .size[1] / 2)};
  if ($a == null or $a.address == null) then empty else
  ($a | center) as $c
  | map(select(.workspace.id == ($ws | tonumber) and .mapped and (.hidden | not) and .address != $a.address)
        | (center) as $w
        | {address, p: (if $dir == "l" then $c.x - $w.x elif $dir == "r" then $w.x - $c.x
                        elif $dir == "u" then $c.y - $w.y else $w.y - $c.y end),
           s: (if $dir == "l" or $dir == "r" then ($w.y - $c.y) else ($w.x - $c.x) end | fabs)}
        | select(.p > 0))
  | min_by(.p + 2 * .s) | .address // empty
  end')

if [ -n "$target" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$target\" })"
else
  # Nothing on this workspace in that direction: fall back to native (crosses monitors)
  hyprctl dispatch "hl.dsp.focus({ direction = \"$dir\" })"
fi
