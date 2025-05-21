#!/bin/bash

# Create directory structure
mkdir -p ~/py-osk
cd ~/py-osk

# Install dependencies
echo "Installing dependencies..."
sudo dnf install -y python3-gobject gtk3

# Create application files

# 1. Main application file (osk.py)
cat > ~/py-osk/osk.py << 'EOL'
#!/usr/bin/env python3
import gi
import os  # <-- THIS WAS MISSING
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk, GLib

class OnScreenKeyboard(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.example.OSK')
        self.keyboard_visible = True
        self.current_layout = 0
        self.shift_state = False
        self.language = 0
        
        # Get screen dimensions
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor() or display.get_monitor(0)
        self.geometry = monitor.get_geometry()
        
        # Keyboard layers (previous content)
        self.main_layout = [
            ['q','w','e','r','t','y','u','i','o','p'],
            ['a','s','d','f','g','h','j','k','l'],
            ['z','x','c','v','b','n','m',',','.']
        ]
        
        self.symbol_layout = [
            ['1','2','3','4','5','6','7','8','9','0'],
            ['-','=','_','+','{','}','[',']','(',')'],
            ['!','@','#','$','%','^','&','*','|','\\'],
            ['/','<','>',',','.','~','`']
        ]
        
        self.russian_layout = [
            ['й','ц','у','к','е','н','г','ш','щ','з','х','ъ'],
            ['ф','ы','в','а','п','р','о','л','д','ж','э'],
            ['я','ч','с','м','и','т','ь','б','ю','.',',']
        ]

    def do_activate(self):
        self.create_toggle_button()
        self.create_keyboard_window()
        GLib.timeout_add(100, self.keep_on_top)

    def create_toggle_button(self):
        self.toggle_btn = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
        self.toggle_btn.set_decorated(False)
        self.toggle_btn.set_skip_taskbar_hint(True)
        self.toggle_btn.set_keep_above(True)
        self.toggle_btn.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        
        btn = Gtk.Button(label="⌨")
        btn.connect("clicked", self.toggle_keyboard)
        self.toggle_btn.add(btn)
        self.toggle_btn.set_default_size(40, 40)
        self.toggle_btn.move(self.geometry.width - 60, self.geometry.height - 60)
        self.toggle_btn.show_all()

    def create_keyboard_window(self):
        self.win = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
        self.win.set_title("On-Screen Keyboard")
        self.win.set_decorated(False)
        self.win.set_keep_above(True)
        self.win.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        
        # Set adaptive size
        keyboard_height = 200
        self.win.set_default_size(self.geometry.width, keyboard_height)
        self.win.move(0, self.geometry.height - keyboard_height)
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        
        # Stack and keyboard layers (same as before)
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        
        self.create_main_layer()
        self.create_symbol_layer()
        self.create_russian_layer()
        
        main_box.pack_start(self.stack, True, True, 0)
        self.win.add(main_box)
        self.win.show_all()


if __name__ == "__main__":
    os.environ["GDK_BACKEND"] = "wayland"
    keyboard = OnScreenKeyboard()
    keyboard.run(None)
EOL

# 2. Create wrapper script
cat > ~/py-osk/start-osk.sh << 'EOL'
#!/bin/bash
export XDG_CURRENT_DESKTOP=GNOME
export GDK_BACKEND=wayland
python3 ~/py-osk/osk.py
EOL

# 3. Create autostart entry
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/py-osk.desktop << EOL
[Desktop Entry]
Type=Application
Name=On-Screen Keyboard
Exec=$HOME/py-osk/start-osk.sh
StartupNotify=false
Terminal=false
EOL

# Set permissions
chmod +x ~/py-osk/start-osk.sh
chmod +x ~/py-osk/osk.py

echo "Installation complete! To start:"
echo "1. Log out and back in, or"
echo "2. Run manually: ~/py-osk/start-osk.sh"
