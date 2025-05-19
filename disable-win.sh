#!/usr/bin/env bash
# ===================================================================
# disable-winkeys-hwdb.sh
# Disable Windows/Super keys by remapping scancodes at the hwdb level
# on Rocky Linux (DNF-based) or any systemd distro.
#
# Usage: sudo ./disable-winkeys-hwdb.sh
# ===================================================================

set -euo pipefail

HWDB_FILE=/etc/udev/hwdb.d/90-disable-winkeys.hwdb

cat > "$HWDB_FILE" << 'EOF'
# Disable Windows/Super keys globally
# Common scancodes on many PC keyboards: db = Left Meta, dc = Right Meta

evdev:input:b0003*
 KEYBOARD_KEY_db=reserved
 KEYBOARD_KEY_dc=reserved
EOF

echo "✔ Wrote hwdb rule to $HWDB_FILE"                      # :contentReference[oaicite:3]{index=3} :contentReference[oaicite:4]{index=4}

echo "🔄 Updating systemd‑hwdb…"
systemd-hwdb update                                       # :contentReference[oaicite:5]{index=5}

echo "🚀 Triggering udev to apply changes…"
udevadm trigger --sysname-match="event*"                  # :contentReference[oaicite:6]{index=6} :contentReference[oaicite:7]{index=7}

echo "✅ Windows/Super keys have been disabled system‑wide!"

