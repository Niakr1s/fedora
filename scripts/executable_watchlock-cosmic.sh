#!/usr/bin/env bash

: "${MAIN_MONITOR:?MAIN_MONITOR environment variable must be set}"
OFF_INTERVAL=30       # Re-apply wlopm --off every N seconds while locked
POLL_INTERVAL=2       # Check lock file every N seconds

screenlock=""
declare -A monitor_states
last_off_time=0

read_monitor_states() {
  monitor_states=()
  while read -r name state; do
    [[ -n "$name" && -n "$state" ]] && monitor_states["$name"]="$state"
  done < <(
    cosmic-randr list --kdl | awk '
      /^output "/ {
        match($0, /^output "([^"]+)"/, m)
        name = m[1]
        if ($0 ~ /enabled=#true/) {
          print name, "true"
        } else if ($0 ~ /enabled=#false/) {
          print name, "false"
        }
      }
    '
  )
}

while true; do
  old_screenlock="$screenlock"
  screenlock=false

  if compgen -G "$XDG_RUNTIME_DIR/cosmic-greeter-*.lock" > /dev/null; then
    screenlock=true
  fi

  # State transition: unlocked -> locked, or locked -> unlocked
  if [[ "$old_screenlock" != "$screenlock" ]]; then
    if [[ "$screenlock" == true ]]; then
      echo "watchlock: reading all monitor states"
      read_monitor_states

      for out in "${!monitor_states[@]}"; do
        echo "watchlock: saved $out -> enabled=${monitor_states[$out]}"
      done

      # Ensure MAIN_MONITOR is enabled first so cosmic-comp always keeps an active head
      echo "watchlock: enabling main monitor $MAIN_MONITOR"
      cosmic-randr enable "$MAIN_MONITOR"

      # Disable all other outputs
      for out in "${!monitor_states[@]}"; do
        if [[ "$out" != "$MAIN_MONITOR" ]]; then
          echo "watchlock: disabling $out"
          cosmic-randr disable "$out"
        fi
      done

      sleep 1
      echo "watchlock: turning off monitors via wlopm"
      wlopm --off "*"
      last_off_time=$(date +%s)

    else
      echo "watchlock: waking monitors via wlopm"
      wlopm --on "*"

      # Restore each monitor to its exact saved enabled/disabled state
      for out in "${!monitor_states[@]}"; do
        if [[ "${monitor_states[$out]}" == "true" ]]; then
          echo "watchlock: restoring $out -> enable"
          cosmic-randr enable "$out"
        else
          echo "watchlock: restoring $out -> disable"
          cosmic-randr disable "$out"
        fi
      done
    fi

  # Still locked: periodically re-issue wlopm --off every OFF_INTERVAL seconds
  elif [[ "$screenlock" == true ]]; then
    now=$(date +%s)
    if (( now - last_off_time >= OFF_INTERVAL )); then
      echo "watchlock: re-applying wlopm --off"
      wlopm --off "*"
      last_off_time=$now
    fi
  fi

  sleep "$POLL_INTERVAL"
done
