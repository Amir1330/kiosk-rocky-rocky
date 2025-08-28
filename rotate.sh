#!/bin/bash
# Rotate GNOME Wayland display automatically

# Find first monitor name
MONITOR=$(gdbus call --session \
  --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.GetResources \
  | grep -o '"connector":"[^"]*"' | head -n1 | cut -d':' -f2 | tr -d '"')

# Transform values
case "$1" in
  normal)   TRANSFORM=0 ;;
  right)    TRANSFORM=1 ;;
  inverted) TRANSFORM=2 ;;
  left)     TRANSFORM=3 ;;
  *) echo "Usage: $0 {normal|right|inverted|left}"; exit 1 ;;
esac

# Apply rotation (note the array + variant syntax!)
gdbus call --session \
  --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig \
  1 "[{'x':0,'y':0,'scale':1,'primary':true,'transform':$TRANSFORM,'monitor_configs':[{'connector':'$MONITOR'}]}]" "{}"