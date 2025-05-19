#!/usr/bin/env bash
# ===================================================================
# disable-winkeys-hwdb.sh
# Fully disable Windows/Super keys on Rocky Linux (or any system
# using systemd‑hwdb) by marking their scancodes as “reserved.”
#
# Usage: sudo bash disable-winkeys-hwdb.sh
# ===================================================================

set -euo pipefail

# 1. Define the hwdb fragment
HWDB_FILE=/etc/udev/hwdb.d/90-disable-winkeys.hwdb

cat > "$HWDB_FILE" << 'EOF'
# Disable Windows / Super keys globally
# (AT keyboard set1 make codes: e07d = Left Meta, e07e = Right Meta)

evdev:input:b0003*
 KEYBOARD_KEY_e07d=reserved
 KEYBOARD_KEY_e07e=reserved
EOF

echo "✔ Wrote hwdb rule to $HWDB_FILE"                # :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

# 2. Rebuild the hardware database
echo "🔄 Updating systemd‑hwdb…"
systemd-hwdb update                                 # :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3}

# 3. Trigger udev to apply the new mapping immediately
echo "🚀 Triggering udev reload on all input devices…"
udevadm trigger --sysname-match="event*"            # :contentReference[oaicite:4]{index=4} :contentReference[oaicite:5]{index=5}

echo
echo "✅ Windows/Super keys are now disabled system-wide!"

