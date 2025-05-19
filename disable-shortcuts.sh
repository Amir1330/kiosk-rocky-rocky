#!/usr/bin/env bash
set -euo pipefail

EXT_ID="aidbmcboeighgdnilpdljbedbbiocphj"
EXT_UPDATE_URL="https://clients2.google.com/service/update2/crx"
EXT_DIR="/usr/share/chromium/extensions"

echo "→ Installing Disable Keyboard Shortcut extension…"

# Ensure the directory exists (root)
sudo mkdir -p "$EXT_DIR"                                             # :contentReference[oaicite:2]{index=2}

# Write the JSON file (root)
sudo tee "$EXT_DIR/${EXT_ID}.json" > /dev/null <<EOF
{
  "external_update_url": "$EXT_UPDATE_URL"
}
EOF

# Set the proper permissions (root)
sudo chmod 644 "$EXT_DIR/${EXT_ID}.json"                             # :contentReference[oaicite:3]{index=3}
sudo chown root:root "$EXT_DIR/${EXT_ID}.json"

echo
echo "✅ Installed Disable Keyboard Shortcut ($EXT_ID)."
echo "   Restart Chromium—extension will auto‑install from the Web Store."

