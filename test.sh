#!/usr/bin/env bash
# ===================================================================
# install-nw-kiosk-full.sh
# Fully automated setup for an NW.js-based kiosk:
#  - Downloads and installs NW.js runtime
#  - Generates app manifest (package.json) with chromium-args
#  - Creates index.html with right-click disabled
#  - Writes a launch wrapper using a fresh user-data dir
#  - Installs autostart .desktop entry
# Usage: bash install-nw-kiosk-full.sh <domain>
# ===================================================================

set -euo pipefail

function usage() {
  echo "Usage: $0 <domain>"
  echo "Example: $0 example.com"
  exit 1
}

# 1) Validate input
if [[ $# -ne 1 ]]; then
  usage
fi

DOMAIN="$1"
BASE_DIR="$HOME/kiosk-nw"
APP_DIR="$BASE_DIR/app"
NW_DIR="$BASE_DIR/nw"
WRAPPER="$HOME/launch-kiosk.sh"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/nwkiosk.desktop"

# 2) Prepare directories
echo "[1/6] Creating directories..."
mkdir -p "$APP_DIR" "$NW_DIR" "$AUTOSTART_DIR"

# 3) Download and extract NW.js
NW_VERSION="0.76.1"
NW_ZIP="nwjs-v${NW_VERSION}-linux-x64.tar.gz"
NW_URL="https://dl.nwjs.io/v${NW_VERSION}/${NW_ZIP}"
TMP_ZIP="/tmp/$NW_ZIP"

echo "[2/6] Downloading NW.js ${NW_VERSION}..."
wget -q --show-progress -O "$TMP_ZIP" "$NW_URL"

echo "[3/6] Extracting NW.js..."
tar -xzf "$TMP_ZIP" -C "$NW_DIR" --strip-components=1
rm -f "$TMP_ZIP"

# 4) Create package.json with chromium-args
echo "[4/6] Writing package.json..."
cat > "$APP_DIR/package.json" <<EOF
{
  "name": "mykiosk",
  "main": "index.html",
  "window": { "fullscreen": true, "toolbar": false },
  "chromium-args": "--kiosk --password-store=basic --disable-save-password-bubble \
    --disable-translate --overscroll-history-navigation=0 \
    --disable-pinch --disable-session-crashed-bubble \
    --disable-features=TranslateUI"
}
EOF

# 5) Create index.html disabling right-click
echo "[5/6] Writing index.html..."
cat > "$APP_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Kiosk</title></head>
<body style="margin:0;overflow:hidden;">
<script>
  window.oncontextmenu = function(e) { e.preventDefault(); e.stopPropagation(); return false; };
  window.location.replace("https://$DOMAIN");
</script>
</body>
</html>
EOF

# 6) Create launch wrapper with fresh user-data-dir
echo "[6/6] Creating launch wrapper and autostart entry..."
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
BASE="$BASE_DIR"
APP="$APP_DIR"
exec "\$BASE/nw" "\$APP" \
  --user-data-dir="\$HOME/.cache/kiosk-profile" \
  \$({ true; } 1>&2)
EOF
chmod +x "$WRAPPER"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=NWKiosk
Exec=$WRAPPER
Terminal=false
EOF
chmod 644 "$DESKTOP_FILE"

echo "\n✅ Installation complete! Log out and back in to start the kiosk."

