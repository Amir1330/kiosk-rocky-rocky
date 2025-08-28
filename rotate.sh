#!/bin/bash
# Rotate ILITEK Multi-Touch-V5000 touchscreen persistently on Wayland (GNOME)
# Usage: sudo ./touch-rotate.sh {normal|right|inverted|left}

DEVICE="ILITEK Multi-Touch-V5000"
HWDB_FILE="/etc/udev/hwdb.d/99-touchscreen.hwdb"

case "$1" in
  normal)
    MATRIX="1 0 0 0 1 0 0 0 1"
    ;;
  right)
    MATRIX="0 -1 1 1 0 0 0 0 1"
    ;;
  inverted)
    MATRIX="-1 0 1 0 -1 1 0 0 1"
    ;;
  left)
    MATRIX="0 1 0 -1 0 1 0 0 1"
    ;;
  *)
    echo "Usage: $0 {normal|right|inverted|left}"
    exit 1
    ;;
esac

echo ">>> Applying rotation '$1' to $DEVICE"
echo ">>> Writing hwdb file: $HWDB_FILE"

cat <<EOF | sudo tee $HWDB_FILE >/dev/null
evdev:name:${DEVICE}*
 LIBINPUT_CALIBRATION_MATRIX=$MATRIX
EOF

echo ">>> Updating hwdb database..."
sudo systemd-hwdb update

echo ">>> Reloading udev rules for touchscreen..."
EVENT=$(grep -l "$DEVICE" /proc/bus/input/devices | grep event | sed 's/.*event//;s/:.*//')
if [ -n "$EVENT" ]; then
  sudo udevadm trigger /dev/input/event$EVENT
fi

echo ">>> Done. Rotation '$1' is now persistent across reboots."