#!/usr/bin/env sh
# Reconcile eDP-1 to the desired state for the current lid + dock situation.
# Idempotent: it issues Hyprland commands only when the panel has actually
# drifted, so it is safe to run every tick. This has to be a reconciler rather
# than a lid-edge handler because Hyprland re-applies its eDP-1 monitor rule on
# every hotplug/reload, silently switching the panel back on while the lid stays
# shut (docking, monitor DPMS wake, `hyprctl reload`, ...). Those events carry
# no lid edge, so only a drift check can catch them.
#
#   lid open                -> panel on    (enabled at its geometry, DPMS on)
#   lid closed + external   -> panel off   (disabled; windows move to external)
#   lid closed + standalone -> panel blank (DPMS off; disabling the only output
#                              leaves Hyprland dark on reopen)

# The Lua config parser rejects `hyprctl keyword`, so drive monitors via eval.
enable='hl.monitor({ output = "eDP-1", mode = "preferred", position = "80x1800", scale = 1.5, disabled = false })'
disable='hl.monitor({ output = "eDP-1", disabled = true })'

mon=$(hyprctl monitors all -j)

if grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
  lid=closed
else
  lid=open
fi

external=$(echo "$mon" | jq 'any(.[]; .name != "eDP-1")')
edp=$(echo "$mon" | jq -r '.[] | select(.name == "eDP-1") | "\(.disabled) \(.dpmsStatus)"')
disabled=${edp% *}
dpms=${edp#* }

if [ "$lid" = "open" ]; then
  if [ "$disabled" != "false" ] || [ "$dpms" != "true" ]; then
    hyprctl eval "$enable"
    hyprctl dispatch dpms on eDP-1
  fi
elif [ "$external" = "true" ]; then
  if [ "$disabled" != "true" ]; then
    hyprctl eval "$disable"
  fi
else
  if [ "$disabled" != "false" ]; then
    hyprctl eval "$enable"
  fi
  if [ "$dpms" != "false" ]; then
    hyprctl dispatch dpms off eDP-1
  fi
fi
