#!/usr/bin/env bash
set -e

APPDIR="$HOME/.local/share/on-screen-keyboard-ru-en"
MAINFILE="$APPDIR/osk_main.py"
REQUIREMENTS="$APPDIR/requirements.txt"
DESKTOP_FILE="$HOME/.config/autostart/on-screen-keyboard-ru-en.desktop"

sudo dnf install -y python3-pip

# 1. Create app directory
mkdir -p "$APPDIR"

# 2. Write main app code
cat > "$MAINFILE" <<'EOF'
import sys
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QStackedWidget, QHBoxLayout
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QIcon

class FloatingButton(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.WindowStaysOnTopHint | Qt.WindowType.Tool)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setFixedSize(60, 60)
        layout = QVBoxLayout(self)
        self.button = QPushButton("\U0001F310")  # Globe symbol
        self.button.setFixedSize(50, 50)
        self.button.setStyleSheet("background: white; border-radius: 25px; font-size: 24px;")
        layout.addWidget(self.button)
        layout.setContentsMargins(5, 5, 5, 5)
        self.setLayout(layout)

class OnScreenKeyboard(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.WindowStaysOnTopHint | Qt.WindowType.Tool)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setStyleSheet("background: #f9f9f9; border-radius: 16px;")
        self.setFixedHeight(350)
        self.setMinimumWidth(900)
        self.layout = QVBoxLayout(self)
        self.setLayout(self.layout)
        # Placeholder for keyboard layers
        self.keyboard_stack = QStackedWidget()
        self.layout.addWidget(self.keyboard_stack)
        # Placeholder for bottom row (space, enter, etc.)
        self.bottom_row = QHBoxLayout()
        self.layout.addLayout(self.bottom_row)

class MainApp(QApplication):
    def __init__(self, argv):
        super().__init__(argv)
        self.setStyle("Fusion")
        self.keyboard = OnScreenKeyboard()
        self.floating_button = FloatingButton()
        self.floating_button.button.clicked.connect(self.toggle_keyboard)
        self.keyboard.hide()
        self.floating_button.show()

    def toggle_keyboard(self):
        if self.keyboard.isVisible():
            self.keyboard.hide()
        else:
            self.keyboard.show()
            self.keyboard.move(200, 600)  # Example position

def main():
    app = MainApp(sys.argv)
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
EOF

# 3. Write requirements.txt
cat > "$REQUIREMENTS" <<EOF
PyQt6
EOF

# 4. Install Python dependencies system-wide
sudo pip install PyQt6

# 5. Install ydotool
sudo dnf install -y ydotool

# 6. Create autostart desktop entry
mkdir -p "$HOME/.config/autostart"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=On-Screen Keyboard RU/EN
Exec=python3 $MAINFILE
X-GNOME-Autostart-enabled=true
Terminal=false
Comment=Modern floating on-screen keyboard (RU/EN/Symbols)
EOF

echo "\nInstallation complete!"
echo "To run the keyboard now:"
echo "  python3 $MAINFILE"
echo "Or log out and log in again to start automatically." 
