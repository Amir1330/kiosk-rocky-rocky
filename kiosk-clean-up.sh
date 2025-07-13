#!/usr/bin/env bash
set -euo pipefail

echo "⚠️  This script will remove all files and configurations created by the kiosk setup."
read -rp "Are you sure you want to continue? (y/N): " confirm
if [[ "${confirm,,}" != "y" ]]; then
  echo "❌ Cancelled."
  exit 1
fi

### 1) Remove Chromium autostart entry
AUTOSTART_FILE="$HOME/.config/autostart/chromiumkiosk.desktop"
if [[ -f "$AUTOSTART_FILE" ]]; then
  rm -f "$AUTOSTART_FILE"
  echo "🗑 Removed autostart file: $AUTOSTART_FILE"
else
  echo "ℹ️  Autostart file not found: $AUTOSTART_FILE"
fi

### 2) Remove downloaded Chromium directory and ZIP
CHROME_DIR="/home/kiosk/chrome-linux"
CHROME_ZIP="/home/kiosk/chrome-linux.zip"

if [[ -d "$CHROME_DIR" ]]; then
  rm -rf "$CHROME_DIR"
  echo "🗑 Removed Chromium directory: $CHROME_DIR"
else
  echo "ℹ️  Chromium directory not found: $CHROME_DIR"
fi

if [[ -f "$CHROME_ZIP" ]]; then
  rm -f "$CHROME_ZIP"
  echo "🗑 Removed Chromium ZIP file: $CHROME_ZIP"
fi

### 3) Remove user 'admin' (optional – be careful!)
if id -u admin >/dev/null 2>&1; then
  echo "⚠️  Attempting to remove user 'admin' and their home directory..."
  sudo deluser --remove-home admin || echo "❌ Failed to delete user 'admin'"
else
  echo "ℹ️  User 'admin' does not exist"
fi

### 4) Remove group 'sysadmins' (if empty)
if getent group sysadmins >/dev/null; then
  if [[ -z "$(getent group sysadmins | cut -d: -f4)" ]]; then
    sudo groupdel sysadmins && echo "🗑 Removed group 'sysadmins'"
  else
    echo "⚠️  Group 'sysadmins' is not empty — not removed"
  fi
else
  echo "ℹ️  Group 'sysadmins' does not exist"
fi

### 5) Reset permissions on gnome-control-center
TARGET_BIN="/usr/bin/gnome-control-center"
if [[ -f "$TARGET_BIN" ]]; then
  sudo chmod 755 "$TARGET_BIN"
  sudo chown root:root "$TARGET_BIN"
  echo "🔁 Restored default ownership and permissions on $TARGET_BIN"
else
  echo "ℹ️  $TARGET_BIN not found"
fi

echo "✅ Cleanup complete!"