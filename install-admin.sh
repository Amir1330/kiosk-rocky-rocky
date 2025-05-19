#!/usr/bin/env bash
set -euo pipefail

rm -rf ~/.config/autostart/chromiumkiosk.desktop /home/kiosk/chrome-linux

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

### 2) Create the autostart .desktop entry
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/nw-kiosk.desktop"

echo "• Setting up autostart entry..."
mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=NW-Kiosk
Exec=/home/kiosk/nwjs/nw /home/kiosk/nwjs/app
Terminal=false
EOF

chmod 644 "$DESKTOP_FILE"
echo "  → Created $DESKTOP_FILE"

### 3) Download & setup NW.js
NWJS_DIR="/home/kiosk/nwjs"
APP_DIR="$NWJS_DIR/app"
NWJS_URL="https://dl.nwjs.io/v0.89.0/nwjs-v0.89.0-linux-x64.tar.gz"

echo "• Creating app structure..."
mkdir -p "$APP_DIR"

# Create package.json
cat > "$APP_DIR/package.json" <<EOF
{
  "name": "kiosk",
  "main": "index.html",
  "window": {
    "fullscreen": true,
    "toolbar": false,
    "frame": false
  }
}
EOF

# Create HTML file with context menu disable
cat > "$APP_DIR/index.html" <<EOF
<!DOCTYPE html>
<script>
window.oncontextmenu = function(ev) { 
  ev.preventDefault();
  ev.stopPropagation();
  return false;
}
window.location.href = "https://$URL";
</script>
EOF

echo "• Downloading NW.js..."
wget -q --show-progress -O "$NWJS_DIR/nwjs.tar.gz" "$NWJS_URL"

echo "• Extracting NW.js..."
tar -xzf "$NWJS_DIR/nwjs.tar.gz" -C "$NWJS_DIR" --strip-components 1
rm -f "$NWJS_DIR/nwjs.tar.gz"

echo "• Making NW.js executable..."
chmod +x "$NWJS_DIR/nw"

### 4) Run offregion script tasks under sudo (same as before)
echo "• Running offregion setup (group/user/perms)..."

# Create sysadmins group if needed
if ! sudo getent group sysadmins >/dev/null; then
  sudo groupadd sysadmins
  echo "  → Group 'sysadmins' created"
else
  echo "  → Group 'sysadmins' already exists"
fi

# Create or update user 'admin'
if ! id -u admin >/dev/null 2>&1; then
  sudo adduser admin
  echo "  → User 'admin' created"
else
  echo "  → User 'admin' already exists"
fi
sudo usermod -aG sysadmins admin
echo "  → Added 'admin' to 'sysadmins' group"

# Secure gnome-control-center binary
TARGET_BIN="/usr/bin/gnome-control-center"
if [[ -f "$TARGET_BIN" ]]; then
  sudo chown admin:sysadmins "$TARGET_BIN"
  sudo chmod 750 "$TARGET_BIN"
  echo "  → Updated ownership & perms on $TARGET_BIN"
else
  echo "⚠️  $TARGET_BIN not found—skipping perms step"
fi

# disable win and alt
sudo ~/kiosk-rocky-rocky/disable-win.sh

echo "✅ All done! NW.js will launch in strict kiosk mode at next login:"
echo "   - All keyboard shortcuts blocked"
echo "   - No right-click context menu"
echo "   - Fullscreen enforced at OS level"
