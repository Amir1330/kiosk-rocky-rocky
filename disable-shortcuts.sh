#!/usr/bin/env bash
# ===================================================================
# install-disable-shortcut.sh
# Auto‑install “Disable Keyboard Shortcut” (aidbmcboeighgdnilpdljbedbbiocphj)
# into Chromium on Linux via the external extensions JSON mechanism.
#
# Usage: sudo ./install-disable-shortcut.sh
# ===================================================================

set -euo pipefail

EXT_ID="aidbmcboeighgdnilpdljbedbbiocphj"
EXT_UPDATE_URL="https://clients2.google.com/service/update2/crx"
# Common paths where Chromium reads external extensions on Linux :contentReference[oaicite:0]{index=0}
EXT_DIR="/usr/share/chromium/extensions"

echo "→ Ensuring external extensions directory exists at $EXT_DIR…"
mkdir -p "$EXT_DIR"                                                    # :contentReference[oaicite:1]{index=1}

JSON_FILE="$EXT_DIR/${EXT_ID}.json"
echo "→ Writing $JSON_FILE to point at the Chrome Web Store…"
cat > "$JSON_FILE" <<EOF
{
  "external_update_url": "$EXT_UPDATE_URL"
}
EOF                                                                     # :contentReference[oaicite:2]{index=2}

echo "→ Setting permissions so Chromium can read it…"
chmod 644 "$JSON_FILE"                                                  # :contentReference[oaicite:3]{index=3}
chown root:root "$JSON_FILE"

echo
echo "✅ Installed Disable Keyboard Shortcut ($EXT_ID)."
echo "   Restart Chromium—extension will auto‑install from the Web Store."

