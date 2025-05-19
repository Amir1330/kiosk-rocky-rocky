#!/usr/bin/env bash
# ===================================================================
# install-chrome-kiosk.sh
# Automated setup for a Chromium-based kiosk using your local
# chrome-linux binaries:
#  - Wraps chrome executable with desired flags
#  - Generates index.html with right-click disabled and redirect logic
#  - Creates a launcher wrapper pointing at chrome with flags
#  - Installs autostart .desktop entry
# Usage: bash install-chrome-kiosk.sh <domain>
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
HOME_BIN="$HOME/chrome-linux"
CHROME_BIN="$HOME_BIN/chrome"
WRAPPER="$HOME/bin/launch-chrome-kiosk"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/chromiumkiosk.desktop"
PROFILE_DIR="$HOME/.cache/chrome-kiosk-profile"

# 2) Ensure chrome binary is present
if [[ ! -x "$CHROME_BIN" ]]; then
  echo "❌ Chrome binary not found or not executable at $CHROME_BIN"
  exit 1
fi

echo "[1/4] Creating launcher wrapper..."
mkdir -p "$(dirname "$WRAPPER")"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
# wrapper for kiosk mode
exec "$CHROME_BIN" \
  --user-data-dir="$PROFILE_DIR" \
  --password-store=basic \
  --kiosk "https://$DOMAIN" \
  --noerrdialogs \
  --disable-infobars \
  --disable-save-password-bubble \
  --disable-translate \
  --overscroll-history-navigation=0 \
  --disable-pinch \
  --disable-session-crashed-bubble \
  --disable-features=TranslateUI
EOF
chmod +x "$WRAPPER"

echo "[2/4] Creating index.html (for embedded pages, optional)..."
# Optional: write a local page that redirects — remove if not used
# mkdir -p "$HOME/bin/kiosk-static"
# cat > "$HOME/bin/kiosk-static/index.html" <<HTML
#<!DOCTYPE html>
#<html><head><meta charset="utf-8"><title>Kiosk</title></head>
#<body style="margin:0;overflow:hidden;">
#<script>
#  window.oncontextmenu = e => { e.preventDefault(); e.stopPropagation(); return false; };
#  window.location.replace("https://$DOMAIN");
#</script>
#</body></html>
#HTML

# 3) Setup autostart
echo "[3/4] Writing autostart entry..."
mkdir -p "$AUTOSTART_DIR"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=ChromeKiosk
Exec=$WRAPPER
Terminal=false
EOF
chmod 644 "$DESKTOP_FILE"

# 4) Create empty profile dir
echo "[4/4] Preparing profile directory..."
mkdir -p "$PROFILE_DIR"


echo "\n✅ Chrome kiosk wrapper installed."
echo "   Log out and back in to launch Chrome in kiosk mode."

