#!/usr/bin/env bash
# ===================================================================
# disable-kiosk-keys.sh
# Disable every GNOME keybinding with <Super> or <Alt>,
# and explicitly disable Alt+F4 (close) in both X11 and Wayland.
# Keeps only Ctrl+Alt+F6.
#
# Usage: ./disable-kiosk-keys.sh
# ===================================================================

set -euo pipefail

echo "🔒 Disabling core Super‑key behavior…"
gsettings set org.gnome.mutter overlay-key ''

echo "🔒 Disabling Super‑drag window‑move…"
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier 'disabled'

echo "🔒 Explicitly disabling Alt+F4 (close)…"
gsettings set org.gnome.desktop.wm.keybindings close "[]"
gsettings set org.gnome.mutter.wayland.keybindings close "[]"

echo "🔒 Scanning and wiping all other <Super> & <Alt> bindings, except switch-to-session-6…"
gsettings list-recursively | \
  grep -E '<Super>|<Alt>' | \
  grep -v 'switch-to-session-6' | \
  awk '{ print $1, $2 }' | \
  sort -u | \
  while read -r schema key; do
    # Skip the ones we just did
    if [[ "$schema $key" =~ (org\.gnome\.desktop\.wm\.keybindings close|org\.gnome\.mutter\.wayland\.keybindings close) ]]; then
      continue
    fi
    echo " • Disabling $schema $key"
    gsettings set "$schema" "$key" "[]"
  done

echo
echo "✅ All Super/Alt‑based shortcuts (including Alt+F4) are now disabled, except Ctrl+Alt+F6."

