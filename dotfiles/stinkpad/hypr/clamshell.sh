#!/usr/bin/env sh
# Lid handler. Docked: drop the laptop panel so windows move to the external
# monitor. Undocked: eDP-1 is the only output, so blank it (DPMS) instead of
# disabling it — disabling the last monitor leaves Hyprland dark on reopen.
case "$1" in
  close)
    if [ "$(hyprctl monitors -j | jq length)" -gt 1 ]; then
      hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
    else
      hyprctl dispatch dpms off eDP-1
    fi
    ;;
  open)
    hyprctl dispatch dpms on eDP-1
    hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "80x1800", scale = 1.5, disabled = false })'
    ;;
esac
