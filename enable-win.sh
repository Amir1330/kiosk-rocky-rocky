#!/usr/bin/env bash
# ===================================================================
# enable-kiosk-keys.sh
# Re-enable default GNOME keybindings previously disabled by
# disable-kiosk-keys.sh.
#
# Usage: ./enable-kiosk-keys.sh
# ===================================================================

set -euo pipefail

echo "🔓 Restoring core Super‑key behavior…"
gsettings reset org.gnome.mutter overlay-key

echo "🔓 Restoring Super‑drag window‑move behavior…"
gsettings reset org.gnome.desktop.wm.preferences mouse-button-modifier

echo "🔓 Re-enabling Alt+F4 (close)…"
gsettings reset org.gnome.desktop.wm.keybindings close || \
  gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"

gsettings reset org.gnome.mutter.wayland.keybindings close || \
  gsettings set org.gnome.mutter.wayland.keybindings close "['<Alt>F4']"

echo "🔓 Scanning and restoring other <Super> & <Alt> bindings (if system defaults exist)…"
gsettings list-recursively | \
  grep -E '<Super>|<Alt>' | \
  grep -v 'switch-to-session-6' | \
  awk '{ print $1, $2 }' | \
  sort -u | \
  while read -r schema key; do
    # Skip keys that were explicitly reset above
    if [[ "$schema $key" =~ (org\.gnome\.desktop\.wm\.keybindings close|org\.gnome\.mutter\.wayland\.keybindings close) ]]; then
      continue
    fi
    echo " • Resetting $schema $key"
    gsettings reset "$schema" "$key" || echo "   ⚠️ Could not reset $schema $key"
  done

echo
echo "✅ Default Super/Alt-based shortcuts have been restored."

