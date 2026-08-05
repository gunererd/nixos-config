#!/usr/bin/env sh
# Tick the clamshell reconciler so eDP-1 tracks the lid + dock situation. This
# polls instead of using `switch:` binds because the panel drifts out of the
# desired state without any lid event: Hyprland re-applies its eDP-1 monitor
# rule on every hotplug/reload, switching the panel back on while the lid stays
# shut. clamshell.sh is idempotent and only acts on drift, so a plain loop
# self-heals that within a tick without reconfiguring monitors every time.
# flock keeps a single instance across restarts.
exec 9>/tmp/clamshell-watch.lock
flock -n 9 || exit 0

while :; do
  sh /home/hippo/.config/hypr/clamshell.sh
  sleep 3
done
