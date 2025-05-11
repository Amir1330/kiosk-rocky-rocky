#!/usr/bin/env bash
set -euo pipefail

# Prompt for domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

# Path to the autostart directory and .desktop file
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/chromiumkiosk.desktop"

# Create the autostart directory if it doesn't exist
mkdir -p "$AUTOSTART_DIR"

# Write the .desktop file
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=ChromiumKiosk
Exec=/home/kiosk/chrome-linux/chrome --password-store=basic --kiosk --noerrdialogs --disable-infobars 'https://$URL'
EOF

# Ensure correct file permissions
chmod 777 "$DESKTOP_FILE"

echo "✅ Autostart entry created at $DESKTOP_FILE"

