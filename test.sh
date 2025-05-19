#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# 0) Prime sudo cache so you aren’t asked twice
# --------------------------------------------------
echo "🔐 Requesting sudo up front…"
sudo -v
# Keep-alive: update existing sudo timestamp until script finishes
( while true; do sudo -n true; sleep 60; done ) &

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

### 1b) Choose engine
echo "Choose kiosk engine:"
echo "  1) Chromium"
echo "  2) Node‑Webkit (nw) with JS right‑click lock"
read -rp "Enter 1 or 2: " ENGINE
if [[ "$ENGINE" != "1" && "$ENGINE" != "2" ]]; then
  echo "❌ Invalid choice. Exiting."
  exit 1
fi

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

if [[ "$ENGINE" == "1" ]]; then
  ### 2) Chromium autostart
  cat > "$AUTOSTART_DIR/chromiumkiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=ChromiumKiosk
Exec=$HOME/chrome-linux/chrome \\
  --password-store=basic --kiosk --noerrdialogs --disable-infobars https://$URL
Terminal=false
EOF

  ### 3) Download & unpack Chromium (as before) …
  # … your existing Chromium download/unzip steps go here …

else
  ### 2) Node‑Webkit (“nw”) autostart
  NW_VERSION="0.76.1"
  NW_ZIP="nwjs-v${NW_VERSION}-linux-x64.tar.gz"
  NW_URL="https://dl.nwjs.io/v${NW_VERSION}/${NW_ZIP}"
  BASE_DIR="$HOME/kiosk-nw"
  APP_DIR="$BASE_DIR/app"
  NW_DIR="$BASE_DIR/nw"

  mkdir -p "$APP_DIR" "$NW_DIR"

  # Download & unpack nw
  wget -q --show-progress -O "/tmp/${NW_ZIP}" "$NW_URL"
  tar -xzf "/tmp/${NW_ZIP}" -C "$NW_DIR" --strip-components=1
  rm -f "/tmp/${NW_ZIP}"

  # package.json
  cat > "$APP_DIR/package.json" <<EOF
{
  "name": "mykiosk",
  "main": "index.html",
  "window": { "fullscreen": true, "toolbar": false }
}
EOF

  # index.html
  cat > "$APP_DIR/index.html" <<EOF
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Kiosk</title></head>
<body style="margin:0;overflow:hidden;">
<script>
  window.oncontextmenu = e => { e.preventDefault(); e.stopPropagation(); return false; };
  window.location.href = "https://$URL";
</script>
</body></html>
EOF

  # **Here’s the change**: we append the same Chromium flags to the nw launch
  cat > "$AUTOSTART_DIR/nwkiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=NWKiosk
Exec=$NW_DIR/nw $APP_DIR \\
  --password-store=basic --kiosk --noerrdialogs --disable-infobars
Terminal=false
EOF
fi


### 4) Run offregion script tasks under sudo
echo "• Running offregion setup (group/user/perms)…"

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

echo
echo "✅ All done! At next login, your chosen kiosk engine will launch https://$URL"

