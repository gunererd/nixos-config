#!/usr/bin/env sh
# Event-driven half of the clamshell setup: reconcile eDP-1 whenever Hyprland
# reports a monitor hotplug or config reload, with no polling. Docking (and
# `hyprctl reload`, which re-applies the eDP-1 monitor rule) carries no lid edge,
# so the lid binds in hyprland.lua can't catch it; this listener does. A
# reconcile also runs once at startup for the lid state already present at launch.
# clamshell.sh is idempotent, so the extra events its own eval emits settle to a
# no-op. flock keeps a single instance across restarts.
exec 9>/tmp/clamshell-watch.lock
flock -n 9 || exit 0

reconcile=/home/hippo/.config/hypr/clamshell.sh
sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

sh "$reconcile"

# Block on the event socket; reconnect only while it still exists (i.e. this
# Hyprland session is alive). When Hyprland exits the socket disappears, the
# loop ends, and flock is released for the next session's listener.
while [ -S "$sock" ]; do
  socat -U - "UNIX-CONNECT:$sock" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      monitoradded*|monitorremoved*|configreloaded*)
        sh "$reconcile"
        ;;
    esac
  done
  sleep 1
done
