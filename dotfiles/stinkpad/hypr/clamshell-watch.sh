#!/usr/bin/env sh
# Poll the lid switch and drive clamshell.sh on state changes. Replaces the
# edge-triggered `switch:` binds, which miss the lid state present at launch or
# after a config reload. Acts only on transitions, so monitors aren't
# reconfigured every tick. flock keeps a single instance across restarts.
exec 9>/tmp/clamshell-watch.lock
flock -n 9 || exit 0

last=""
while :; do
  if grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
    state=close
  else
    state=open
  fi
  if [ "$state" != "$last" ]; then
    sh /home/hippo/.config/hypr/clamshell.sh "$state"
    last=$state
  fi
  sleep 3
done
