#!/bin/bash

# Create directory structure
mkdir -p ~/py-osk
cd ~/py-osk

# Install dependencies
echo "Installing dependencies..."
sudo dnf install -y python3-gobject gtk3 xdotool

# Create application files with debug logging
cat > ~/py-osk/osk.py << 'EOL'
#!/usr/bin/env python3
import gi
import os
import logging

gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk, GLib

# Set up logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger('OSK')

class OnScreenKeyboard(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.example.OSK')
        self.keyboard_visible = True
        self.current_layout = 0
        self.shift_state = False
        self.language = 0
        self.win = None
        self.toggle_btn = None
        self.geometry = None
        
        # Initialize in proper GTK thread
        GLib.idle_add(self.initialize)

    def initialize(self):
        try:
            logger.debug("Initializing application...")
            display = Gdk.Display.get_default()
            monitor = display.get_primary_monitor() or display.get_monitor(0)
            self.geometry = monitor.get_geometry()
            logger.debug(f"Screen geometry: {self.geometry.width}x{self.geometry.height}")

            self.create_toggle_button()
            self.create_keyboard_window()
            GLib.timeout_add(100, self.keep_on_top)
        except Exception as e:
            logger.error(f"Initialization error: {str(e)}")
        return False

    def create_toggle_button(self):
        try:
            logger.debug("Creating toggle button...")
            self.toggle_btn = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
            self.toggle_btn.set_title("OSK Toggle")
            self.toggle_btn.set_decorated(False)
            self.toggle_btn.set_skip_taskbar_hint(True)
            self.toggle_btn.set_keep_above(True)
            self.toggle_btn.set_type_hint(Gdk.WindowTypeHint.UTILITY)
            
            btn = Gtk.Button(label="⌨")
            btn.connect("clicked", self.toggle_keyboard)
            self.toggle_btn.add(btn)
            self.toggle_btn.set_default_size(40, 40)
            self.toggle_btn.move(self.geometry.width - 100, self.geometry.height - 100)
            self.toggle_btn.show_all()
            logger.debug("Toggle button created")
        except Exception as e:
            logger.error(f"Toggle button error: {str(e)}")

    def create_keyboard_window(self):
        try:
            logger.debug("Creating main keyboard window...")
            self.win = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
            self.win.set_title("On-Screen Keyboard")
            self.win.set_decorated(False)
            self.win.set_keep_above(True)
            self.win.set_type_hint(Gdk.WindowTypeHint.UTILITY)
            
            keyboard_height = 200
            self.win.set_default_size(self.geometry.width, keyboard_height)
            self.win.move(0, self.geometry.height - keyboard_height)
            
            main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            
            self.stack = Gtk.Stack()
            self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
            
            self.create_main_layer()
            self.create_symbol_layer()
            self.create_russian_layer()
            
            main_box.pack_start(self.stack, True, True, 0)
            self.win.add(main_box)
            self.win.show_all()
            logger.debug("Keyboard window created")
        except Exception as e:
            logger.error(f"Keyboard window error: {str(e)}")

    # ... [Keep all other methods from previous version] ...

    def do_activate(self):
        logger.debug("Application activated")

if __name__ == "__main__":
    try:
        logger.debug("Starting application...")
        os.environ["GDK_BACKEND"] = "wayland"
        app = OnScreenKeyboard()
        app.run(None)
    except Exception as e:
        logger.error(f"Main execution error: {str(e)}")
EOL

# Create debug script
cat > ~/py-osk/debug.sh << 'EOL'
#!/bin/bash
export GDK_DEBUG=interactive
export GTK_DEBUG=interactive
export XDG_CURRENT_DESKTOP=GNOME
export GDK_BACKEND=wayland
python3 ~/py-osk/osk.py
EOL

# Set permissions
chmod +x ~/py-osk/osk.py
chmod +x ~/py-osk/debug.sh

echo "Installation complete! To debug:"
echo "~/py-osk/debug.sh"
