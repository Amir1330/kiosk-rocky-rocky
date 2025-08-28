#!/bin/bash
# Rotate ILITEK Multi-Touch-V5000 touchscreen on Wayland (GNOME)

DEVICE="ILITEK Multi-Touch-V5000"
EVENT="/dev/input/event7"

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

echo "Applying rotation '$1' to $DEVICE ($EVENT)"
sudo udevadm hwdb --update
sudo udevadm trigger $EVENT
sudo libinput debug-events --device=$EVENT --verbose | head -n 5 &
sleep 1
sudo kill $!
sudo libinput debug-events --device=$EVENT --set-calibration-matrix=$MATRIX