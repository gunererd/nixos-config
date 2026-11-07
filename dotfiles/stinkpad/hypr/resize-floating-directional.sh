#!/bin/bash
# Grow (right/down) or shrink (left/up) the active floating window by STEP px, centered in place.
STEP=${2:-80}
DW=0; DH=0
case "$1" in
  left)  DW=-$STEP ;;
  right) DW=$STEP ;;
  up)    DH=-$STEP ;;
  down)  DH=$STEP ;;
  *) echo "usage: $0 left|right|up|down [step]"; exit 1 ;;
esac
hyprctl dispatch "hl.dsp.window.resize({ x = $DW, y = $DH, relative = true })" >/dev/null
hyprctl dispatch "hl.dsp.window.move({ x = $(( -DW / 2 )), y = $(( -DH / 2 )), relative = true })" >/dev/null
