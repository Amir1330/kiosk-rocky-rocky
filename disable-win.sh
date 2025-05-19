#!/usr/bin/env bash
# ===================================================================
# disable-winkeys.sh
# A script to install/configure keyd on Rocky Linux and disable
# both the left and right Win (Meta) keys system-wide.
#
# Usage: sudo ./disable-winkeys.sh
# ===================================================================

set -euo pipefail

# 1. Ensure we’re running as root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  Please run this script as root (e.g. sudo $0)"
  exit 1
fi

# 2. Install keyd (via EPEL) if it isn’t already present
if ! command -v keyd &>/dev/null; then
  echo "🔍 keyd not found—enabling EPEL and installing keyd..."
  dnf install -y epel-release
  dnf install -y keyd
else
  echo "✔ keyd is already installed."
fi

# 3. Write the keyd config to disable Meta keys
echo "✏️  Writing /etc/keyd/default.conf…"
cat > /etc/keyd/default.conf << 'EOF'
[ids]
*     # apply to all keyboards

[main]
leftmeta  = noop
rightmeta = noop
EOF

# 4. Enable and (re)start the keyd service
echo "▶️  Enabling and restarting keyd.service…"
systemctl enable keyd.service
systemctl restart keyd.service

echo
echo "✅ Windows (Meta) keys have been disabled!"
echo "   To revert, simply edit /etc/keyd/default.conf and remove the leftmeta/rightmeta lines, then:"
echo "     sudo systemctl restart keyd.service"

