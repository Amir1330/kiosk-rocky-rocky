#!/usr/bin/env bash
# ===================================================================
# disable-kiosk-shortcuts.sh
# Disable Super, Alt+F4, and other risky shortcuts in GNOME
# for a locked‑down kiosk environment.
#
# Usage: ./disable-kiosk-shortcuts.sh
# ===================================================================

set -euo pipefail

echo "🔒 Disabling Super key (Activities overview)…"
gsettings set org.gnome.mutter overlay-key ''

echo "🔒 Disabling Super‑drag (window move)…"
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier 'disabled'

echo "🔒 Disabling Alt+F4 (close window)…"
gsettings set org.gnome.desktop.wm.keybindings close "[]"

echo "🔒 Disabling Alt+Tab and Alt+` (window switch)…"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "[]"

echo "🔒 Disabling Super+Tab (application switch)…"
gsettings set org.gnome.shell.keybindings switch-applications "[]"
gsettings set org.gnome.shell.keybindings switch-applications-backward "[]"

echo "🔒 Disabling Run dialog (Alt+F2)…"
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "[]"

echo "🔒 Disabling terminal hotkey (Ctrl+Alt+T)…"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"

echo "🔒 Disabling lock screen (Ctrl+Alt+L)…"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"

echo
echo "✅ All specified shortcuts have been disabled."
echo "   If you need to restore any, use 'gsettings reset <schema> <key>'."

