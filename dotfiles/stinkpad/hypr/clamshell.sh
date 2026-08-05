#!/usr/bin/env sh
# Reconcile eDP-1 (and, when docked, the external) to the desired state for the
# current lid + dock situation. Idempotent: acts only on drift, so it is safe to
# run on any lid bind or monitor event.
#
# Reliable Hyprland primitives under the Lua config parser (learned the hard way):
#   - disable a monitor:   hl.monitor({ disabled = true })        works
#   - re-enable a monitor:  hl.monitor({ disabled = false })      SILENT NO-OP once
#       eDP-1 is the only output (headless fallback); only `hyprctl reload`, which
#       re-applies the monitor rules from the config, brings it back
#   - dpms on/off:         hl.dispatch(hl.dsp.dpms('on'|'off',NAME))  works
#       (`hyprctl dispatch dpms ...` is reparsed as Lua and errors out)
#
#   lid open                -> panel on   (reload if it was disabled, else dpms on)
#   lid closed + external   -> panel off, and make sure the external is awake:
#       resuming from suspend can leave the external disabled or DPMS-blanked, so
#       reload if it came back disabled, else DPMS it back on
#   lid closed + standalone -> panel off  (dpms-blank if on; if it is already
#                              disabled, leave it — don't strand Hyprland headless)

disable='hl.monitor({ output = "eDP-1", disabled = true })'
dpms_on="hl.dispatch(hl.dsp.dpms('on','eDP-1'))"
dpms_off="hl.dispatch(hl.dsp.dpms('off','eDP-1'))"

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
  if echo "$mon" | jq -e 'any(.[]; .name != "eDP-1" and .disabled == true)' >/dev/null; then
    hyprctl reload
  else
    for m in $(echo "$mon" | jq -r '.[] | select(.name != "eDP-1" and .dpmsStatus == false) | .name'); do
      hyprctl eval "hl.dispatch(hl.dsp.dpms('on','$m'))"
    done
  fi
else
  if [ "$disabled" = "false" ] && [ "$dpms" != "false" ]; then
    hyprctl eval "$dpms_off"
  fi
fi
