# Update osk.py with all required methods
cat > ~/py-osk/osk.py << 'EOL'
#!/usr/bin/env python3
import gi
import os
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
        
        # Keyboard layers
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
        self.win.set_decorated(False)
        self.win.set_keep_above(True)
        self.win.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        
        # Adaptive sizing
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

    # ADD THE MISSING METHOD HERE
    def toggle_keyboard(self, button):
        self.keyboard_visible = not self.keyboard_visible
        self.win.set_visible(self.keyboard_visible)

    # REST OF THE METHODS (create_row, create_main_layer, etc.)
    def create_row(self, keys, layout):
        row = Gtk.Box(spacing=3)
        for key in keys:
            btn = Gtk.Button(label=key)
            btn.set_size_request(60, 40)
            btn.connect("clicked", self.on_key_pressed)
            row.pack_start(btn, False, False, 0)
        layout.pack_start(row, False, False, 3)

    def create_main_layer(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        
        self.create_row(self.main_layout[0], box)
        self.create_row(self.main_layout[1], box)
        
        shift = Gtk.Button(label="⇧")
        shift.connect("clicked", self.toggle_shift)
        row3 = Gtk.Box(spacing=3)
        row3.pack_start(shift, False, False, 0)
        
        self.create_row(self.main_layout[2], box)
        
        # Bottom row
        bottom_row = Gtk.Box(spacing=3)
        lang_btn = Gtk.Button(label="🌐")
        lang_btn.connect("clicked", self.toggle_language)
        num_btn = Gtk.Button(label="123")
        num_btn.connect("clicked", lambda x: self.switch_layout(1))
        space = Gtk.Button(label=" ")
        space.set_size_request(300, 40)
        backspace = Gtk.Button(label="⌫")
        backspace.connect("clicked", self.on_backspace)
        enter = Gtk.Button(label="⏎")
        hide_btn = Gtk.Button(label="▼")
        hide_btn.connect("clicked", self.hide_keyboard)
        
        bottom_row.pack_start(num_btn, False, False, 0)
        bottom_row.pack_start(lang_btn, False, False, 0)
        bottom_row.pack_start(space, True, True, 0)
        bottom_row.pack_start(backspace, False, False, 0)
        bottom_row.pack_start(enter, False, False, 0)
        bottom_row.pack_start(hide_btn, False, False, 0)
        
        box.pack_start(bottom_row, False, False, 0)
        self.stack.add_titled(box, "main", "Main")

    def create_symbol_layer(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        self.create_row(self.symbol_layout[0], box)
        self.create_row(self.symbol_layout[1], box)
        self.create_row(self.symbol_layout[2], box)
        self.create_row(self.symbol_layout[3], box)
        
        bottom_row = Gtk.Box(spacing=3)
        back_btn = Gtk.Button(label="ABC")
        back_btn.connect("clicked", lambda x: self.switch_layout(0))
        space = Gtk.Button(label=" ")
        space.set_size_request(300, 40)
        bottom_row.pack_start(back_btn, False, False, 0)
        bottom_row.pack_start(space, True, True, 0)
        box.pack_start(bottom_row, False, False, 0)
        self.stack.add_titled(box, "symbols", "Symbols")

    def create_russian_layer(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        self.create_row(self.russian_layout[0], box)
        self.create_row(self.russian_layout[1], box)
        self.create_row(self.russian_layout[2], box)
        
        bottom_row = Gtk.Box(spacing=3)
        back_btn = Gtk.Button(label="ABC")
        back_btn.connect("clicked", lambda x: self.switch_layout(0))
        space = Gtk.Button(label=" ")
        space.set_size_request(300, 40)
        bottom_row.pack_start(back_btn, False, False, 0)
        bottom_row.pack_start(space, True, True, 0)
        box.pack_start(bottom_row, False, False, 0)
        self.stack.add_titled(box, "russian", "Russian")

    def on_key_pressed(self, button):
        text = button.get_label()
        print(f"Key pressed: {text}")

    def on_backspace(self, button):
        print("Backspace pressed")

    def toggle_shift(self, button):
        self.shift_state = not self.shift_state

    def toggle_language(self, button):
        self.language = (self.language + 1) % 2
        self.stack.set_visible_child_name("russian" if self.language else "main")

    def switch_layout(self, layout):
        self.current_layout = layout
        self.stack.set_visible_child_name(["main", "symbols", "russian"][layout])

    def hide_keyboard(self, button):
        self.keyboard_visible = False
        self.win.hide()

    def keep_on_top(self):
        self.win.set_keep_above(True)
        self.toggle_btn.set_keep_above(True)
        return True

if __name__ == "__main__":
    os.environ["GDK_BACKEND"] = "wayland"
    keyboard = OnScreenKeyboard()
    keyboard.run(None)
EOL

# Set permissions and restart
chmod +x ~/py-osk/osk.py
pkill -f osk.py
~/py-osk/start-osk.sh
