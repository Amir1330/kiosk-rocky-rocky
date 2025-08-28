#!/bin/bash
# rotate.sh – Rotate GNOME Wayland display easily

# Get first connected monitor name
MONITOR=$(gdbus call --session \
  --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.GetResources \
  | grep -o '"connector":"[^"]*"' | head -n1 | cut -d':' -f2 | tr -d '"')

# Pick transform value based on argument
case "$1" in
  normal)   TRANSFORM=0 ;;
  right)    TRANSFORM=1 ;;
  inverted) TRANSFORM=2 ;;
  left)     TRANSFORM=3 ;;
  *) echo "Usage: $0 {normal|right|inverted|left}"; exit 1 ;;
esac

# Apply rotation
gdbus call --session \
  --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig \
  1 "[{'logical_monitors':[{'x':0,'y':0,'scale':1,'primary':true,'transform':$TRANSFORM,'monitor_configs':[{'id':'$MONITOR'}]}]}]"