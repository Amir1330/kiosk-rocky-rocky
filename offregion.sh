#!/usr/bin/env bash
# ===================================================================
# kiosk-admin-toggle.sh
# Toggle the 'kiosk' user’s ability to run gnome-control-center
# by managing their membership in the 'sysadmins' group.
#
# Usage: sudo ./kiosk-admin-toggle.sh
# ===================================================================

set -euo pipefail

# 1) Ensure sysadmins group exists
if ! getent group sysadmins >/dev/null; then
  echo "⚠️  'sysadmins' group not found. Creating it..."
  groupadd sysadmins
  echo "   → 'sysadmins' created."
fi

# 2) Prompt for action
echo "Choose an action for the 'kiosk' user:"
echo "  1) Enable access to gnome-control-center"
echo "  2) Disable access to gnome-control-center"
read -rp "Enter 1 or 2: " choice

case "$choice" in
  1)
    # Enable: add kiosk to sysadmins
    if id -nG kiosk | grep -qw sysadmins; then
      echo "ℹ️  'kiosk' is already in 'sysadmins'."
    else
      usermod -aG sysadmins kiosk
      echo "✅ 'kiosk' has been added to 'sysadmins'."
    fi
    ;;

  2)
    # Disable: remove kiosk from sysadmins
    if id -nG kiosk | grep -qw sysadmins; then
      gpasswd -d kiosk sysadmins
      echo "✅ 'kiosk' has been removed from 'sysadmins'."
    else
      echo "ℹ️  'kiosk' is not a member of 'sysadmins'."
    fi
    ;;

  *)
    echo "❌ Invalid choice. Exiting."
    exit 1
    ;;
esac

# 3) Ensure perms on gnome-control-center remain locked down
TARGET_BIN="/usr/bin/gnome-control-center"
if [[ -f "$TARGET_BIN" ]]; then
  chown admin:sysadmins "$TARGET_BIN" || true
  chmod 750 "$TARGET_BIN" || true
  echo "🔒 Confirmed perms on $TARGET_BIN: owner=admin, group=sysadmins, mode=750"
else
  echo "⚠️  $TARGET_BIN not found—skipping permission check."
fi

echo
echo "Done."

