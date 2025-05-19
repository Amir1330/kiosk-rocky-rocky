#!/usr/bin/env bash
# ===================================================================
# disable-kiosk-keys.sh
# Disable every GNOME keybinding with <Super> or <Alt>,
# except keep Ctrl+Alt+F6 (switch-to-session-6).
#
# Usage: ./disable-kiosk-keys.sh
# ===================================================================

set -euo pipefail

echo "🔒 Disabling core Super‑key behavior…"
gsettings set org.gnome.mutter overlay-key ''

echo "🔒 Disabling Super‑drag window‑move…"
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier 'disabled'

echo "🔒 Scanning and wiping all other <Super> & <Alt> bindings, except switch-to-session-6…"
# Gather all schema/key pairs with <Super> or <Alt>, except switch-to-session-6
gsettings list-recursively | \
  grep -E '<Super>|<Alt>' | \
  grep -v 'switch-to-session-6' | \
  awk '{ print $1, $2 }' | \
  sort -u | \
  while read -r schema key; do
    # Resetting each binding to empty array
    echo " • Disabling $schema $key"
    gsettings set "$schema" "$key" "[]"
  done

echo
echo "✅ All Super/Alt‑based shortcuts are disabled, except Ctrl+Alt+F6."

