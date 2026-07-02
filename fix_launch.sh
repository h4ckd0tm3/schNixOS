#!/usr/bin/env bash
#
# fix_launch.sh — recover stuck nix-darwin GUI launch agents.
#
# Symptom this fixes:
#   yabai / skhd / jankyborders / sketchybar are not running after login.
#   `launchctl print gui/$UID/org.nixos.<svc>` shows them stuck in launchd's
#   penalty box:
#
#       state = spawn scheduled
#       runs = 1
#       last exit code = 78: EX_CONFIG
#       properties = ... | penalty box | ...
#
# Why it happens:
#   All four are GUI/WindowServer-connecting apps. If they launch once before
#   the Aqua session / WindowServer is ready (a boot-time race, sometimes
#   nudged by a `nix flake update` / partial `darwin-rebuild`), they exit 78
#   (EX_CONFIG). launchd's crash-throttling ("penalty box") then refuses to
#   respawn them, so they stay dead even though the binaries and configs are
#   fine.
#
# The fix:
#   bootout + bootstrap each agent clears the penalty box and starts it fresh.
#   (Re-running `darwin-rebuild switch` does the same thing during activation,
#   so that is the canonical recovery if you are reapplying your config anyway.)
#
# Usage:
#   ./fix_launch.sh

set -euo pipefail

UID_NUM="$(id -u)"
SERVICES=(yabai skhd jankyborders sketchybar)

for svc in "${SERVICES[@]}"; do
  label="org.nixos.${svc}"
  plist="${HOME}/Library/LaunchAgents/${label}.plist"

  if [[ ! -f "${plist}" ]]; then
    echo "skip ${svc}: no plist at ${plist}"
    continue
  fi

  echo "=== ${svc}: bootout + bootstrap ==="
  # bootout may fail if it is not currently loaded; that is fine.
  launchctl bootout "gui/${UID_NUM}/${label}" 2>/dev/null || true
  launchctl bootstrap "gui/${UID_NUM}" "${plist}"
done

sleep 2

echo
echo "=== status ==="
for svc in "${SERVICES[@]}"; do
  label="org.nixos.${svc}"
  echo "--- ${svc} ---"
  launchctl print "gui/${UID_NUM}/${label}" 2>/dev/null \
    | grep -iE 'state =|last exit|pid =|runs =' | head -4 \
    || echo "  not loaded"
done
