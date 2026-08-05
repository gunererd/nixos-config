#!/usr/bin/env sh
# Reconcile the laptop panel (and, when docked, the external) to the desired
# state for the current lid + dock situation. Idempotent: acts only on drift, so
# it is safe to run on any lid bind or monitor event.
#
# Reliable Hyprland primitives under the Lua config parser (learned the hard way):
#   - disable a monitor:   hl.monitor({ disabled = true })        works
#   - re-enable a monitor:  hl.monitor({ disabled = false })      SILENT NO-OP once
#       the panel is the only output (headless fallback); only `hyprctl reload`,
#       which re-applies the monitor rules from the config, brings it back
#   - dpms on/off:         hl.dispatch(hl.dsp.dpms('on'|'off',NAME))  works
#       (`hyprctl dispatch dpms ...` is reparsed as Lua and errors out)
#
#   lid open                -> panel on   (reload if it was disabled, else dpms on)
#   lid closed + external   -> panel off, and make sure the external is awake:
#       resuming from suspend can leave the external disabled or DPMS-blanked, so
#       reload if it came back disabled, else DPMS it back on
#   lid closed + standalone -> panel off  (dpms-blank if on; if it is already
#                              disabled, leave it — don't strand Hyprland headless)

# ---- per-laptop config (change these when moving to another machine) ----------
# Internal panel output name — verify with `hyprctl monitors`.
panel="eDP-1"
# Lid switch state file(s), unquoted so the glob expands — verify the path exists
# with `ls /proc/acpi/button/lid/`.
lid_state=/proc/acpi/button/lid/*/state
# The panel geometry, the external monitor rule, and the "Lid Switch" bind name
# live in hyprland.lua (re-enable happens via `hyprctl reload`, which reads it) —
# those are the other values to adjust per laptop.
# ------------------------------------------------------------------------------

disable="hl.monitor({ output = \"$panel\", disabled = true })"
dpms_on="hl.dispatch(hl.dsp.dpms('on','$panel'))"
dpms_off="hl.dispatch(hl.dsp.dpms('off','$panel'))"

mon=$(hyprctl monitors all -j)

if grep -q closed $lid_state 2>/dev/null; then
  lid=closed
else
  lid=open
fi

external=$(echo "$mon" | jq --arg p "$panel" 'any(.[]; .name != $p)')
edp=$(echo "$mon" | jq -r --arg p "$panel" '.[] | select(.name == $p) | "\(.disabled) \(.dpmsStatus)"')
disabled=${edp% *}
dpms=${edp#* }

if [ "$lid" = "open" ]; then
  if [ "$disabled" != "false" ]; then
    hyprctl reload
  elif [ "$dpms" != "true" ]; then
    hyprctl eval "$dpms_on"
  fi
elif [ "$external" = "true" ]; then
  if [ "$disabled" != "true" ]; then
    hyprctl eval "$disable"
  fi
  # An external that resumed disabled needs a reload; one that is only DPMS-off
  # just needs waking. Both leave the screen black otherwise.
  if echo "$mon" | jq -e --arg p "$panel" 'any(.[]; .name != $p and .disabled == true)' >/dev/null; then
    hyprctl reload
  else
    for m in $(echo "$mon" | jq -r --arg p "$panel" '.[] | select(.name != $p and .dpmsStatus == false) | .name'); do
      hyprctl eval "hl.dispatch(hl.dsp.dpms('on','$m'))"
    done
  fi
else
  if [ "$disabled" = "false" ] && [ "$dpms" != "false" ]; then
    hyprctl eval "$dpms_off"
  fi
fi
