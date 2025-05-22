#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

### 2) Create the autostart .desktop entry
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/chromiumkiosk.desktop"

echo "• Setting up autostart entry..."
mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=ChromiumKiosk
Exec=/home/kiosk/chrome-linux/chrome --password-store=basic --kiosk --noerrdialogs --disable-infobars https://$URL
Terminal=false
EOF

chmod 644 "$DESKTOP_FILE"
echo "  → Created $DESKTOP_FILE"

### 3) Download & unpack Chromium (owned by kiosk)
DOWNLOAD_DIR="/home/kiosk"
ZIP_NAME="chrome-linux.zip"
ZIP_PATH="$DOWNLOAD_DIR/$ZIP_NAME"
CHROME_SNAPSHOT_URL="https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/1458586/chrome-linux.zip"

echo "• Downloading Chromium build to $ZIP_PATH..."
wget -q --show-progress -P "$DOWNLOAD_DIR" "$CHROME_SNAPSHOT_URL"

echo "• Unzipping..."
unzip -o "$ZIP_PATH" -d "$DOWNLOAD_DIR"
echo "  → Chromium unpacked to $DOWNLOAD_DIR/chrome-linux/"

echo "• Removing ZIP archive..."
rm -f "$ZIP_PATH"     # now owned by kiosk, so no sudo needed
echo "  → Removed $ZIP_PATH"

### 4) Run offregion script tasks under sudo
echo "• Running offregion setup (group/user/perms)..."

# 4.1 Create sysadmins group if needed
if ! sudo getent group sysadmins >/dev/null; then
  sudo groupadd sysadmins
  echo "  → Group 'sysadmins' created"
else
  echo "  → Group 'sysadmins' already exists"
fi

# 4.2 Create or update user 'admin'
if ! id -u admin >/dev/null 2>&1; then
  sudo adduser admin
  echo "  → User 'admin' created"
else
  echo "  → User 'admin' already exists"
fi
sudo usermod -aG sysadmins admin
echo "  → Added 'admin' to 'sysadmins' group"

# 4.3 Secure gnome-control-center binary
TARGET_BIN="/usr/bin/gnome-control-center"
if [[ -f "$TARGET_BIN" ]]; then
  sudo chown admin:sysadmins "$TARGET_BIN"
  sudo chmod 750 "$TARGET_BIN"
  echo "  → Updated ownership & perms on $TARGET_BIN"
else
  echo "⚠️  $TARGET_BIN not found—skipping perms step"
fi




echo "✅ All done! At next login, Chromium will launch in kiosk mode at https://$URL"

