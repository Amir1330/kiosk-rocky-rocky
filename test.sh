#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for your kiosk URL
read -rp "Enter the domain (e.g. example.com): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No URL—exiting."
  exit 1
fi

### 2) Set up Node‑Webkit kiosk
NW_VERSION="0.76.1"
NW_ZIP="nwjs-v${NW_VERSION}-linux-x64.tar.gz"
NW_URL="https://dl.nwjs.io/v${NW_VERSION}/${NW_ZIP}"
BASE_DIR="$HOME/kiosk-nw"
APP_DIR="$BASE_DIR/app"
NW_DIR="$BASE_DIR/nw"
AUTOSTART="$HOME/.config/autostart/nwkiosk.desktop"

echo "• Preparing directories…"
mkdir -p "$APP_DIR" "$NW_DIR" "$(dirname "$AUTOSTART")"

echo "• Downloading nw.js ${NW_VERSION}…"
wget -q --show-progress -O "/tmp/${NW_ZIP}" "$NW_URL"
tar -xzf "/tmp/${NW_ZIP}" -C "$NW_DIR" --strip-components=1
rm -f "/tmp/${NW_ZIP}"

echo "• Writing package.json…"
cat > "$APP_DIR/package.json" <<EOF
{
  "name": "mykiosk",
  "main": "index.html",
  "window": {
    "fullscreen": true,
    "toolbar": false
  }
}
EOF

echo "• Writing index.html (right‑click disabled)…"
cat > "$APP_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Kiosk</title></head>
<body style="margin:0;overflow:hidden;">
<script>
  // disable right‑click
  window.oncontextmenu = e => { e.preventDefault(); e.stopPropagation(); return false; };
  // navigate to URL
  window.location.replace("https://$URL");
</script>
</body>
</html>
EOF

echo "• Creating autostart entry…"
cat > "$AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Name=NWKiosk
Exec=$NW_DIR/nw $APP_DIR \\
  --password-store=basic --kiosk --noerrdialogs --disable-infobars
Terminal=false
EOF
chmod 644 "$AUTOSTART"

echo
echo "✅ NW kiosk installed. Log out and back in—nw.js will launch without asking for a password."

