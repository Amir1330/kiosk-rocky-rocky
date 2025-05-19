#!/usr/bin/env bash
# ===================================================================
# disable-super-gnome.sh
# Disable the Super (Win) key and all Super+ shortcuts in GNOME
# on Rocky Linux.
#
# Usage: bash disable-super-gnome.sh
# ===================================================================

set -euo pipefail

# 1. Disable the “overlay” Super key (which opens Activities)
gsettings set org.gnome.mutter overlay-key ''                                # :contentReference[oaicite:0]{index=0}

# 2. Disable Super+Number application shortcuts (1–9)
for i in {1..9}; do
  gsettings set org.gnome.shell.keybindings switch-to-application-"$i" "[]"  # :contentReference[oaicite:1]{index=1}
done

# 3. Disable Super+Drag (move windows) if you like
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier 'disabled'  # :contentReference[oaicite:2]{index=2}

# 4. (Optional) Clear all other Super‑based custom keybindings
#    This finds every keybinding containing “<Super>” and unsets it.
while read -r schema key; do
  gsettings set "$schema" "$key" "[]" 2>/dev/null || true
done < <(gsettings list-recursively | grep '<Super>' | awk '{print $1, $2}')

echo "✅ All Super (Win) key functionality has been disabled."

