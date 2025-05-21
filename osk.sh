#!/usr/bin/env bash
set -e

APPDIR="$HOME/.local/share/on-screen-keyboard-ru-en"
MAINFILE="$APPDIR/osk_main.py"
REQUIREMENTS="$APPDIR/requirements.txt"
DESKTOP_FILE="$HOME/.config/autostart/on-screen-keyboard-ru-en.desktop"

# 1. Create app directory
mkdir -p "$APPDIR"

# 2. Write main app code
cat > "$MAINFILE" <<'EOF'
import sys
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QPushButton, QHBoxLayout, QGridLayout, QSizePolicy
)
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QGuiApplication

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
        self.layout = QVBoxLayout(self)
        self.setLayout(self.layout)
        self.create_keyboard()
        self.resize_to_bottom()
        QTimer.singleShot(100, self.resize_to_bottom)

    def create_keyboard(self):
        # QWERTY layout
        keys = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"],
        ]
        grid = QGridLayout()
        for row, key_row in enumerate(keys):
            for col, key in enumerate(key_row):
                btn = QPushButton(key)
                btn.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
                btn.setMinimumHeight(48)
                btn.setStyleSheet("font-size: 20px; background: #fff; border-radius: 8px;")
                grid.addWidget(btn, row, col)
        self.layout.addLayout(grid)
        # Bottom row: space and enter
        bottom_row = QHBoxLayout()
        space = QPushButton("Space")
        space.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        space.setMinimumHeight(48)
        space.setStyleSheet("font-size: 20px; background: #fff; border-radius: 8px;")
        enter = QPushButton("Enter")
        enter.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        enter.setMinimumHeight(48)
        enter.setStyleSheet("font-size: 20px; background: #fff; border-radius: 8px;")
        bottom_row.addWidget(space, 4)
        bottom_row.addWidget(enter, 1)
        self.layout.addLayout(bottom_row)

    def resize_to_bottom(self):
        screen = QGuiApplication.primaryScreen().geometry()
        width = screen.width()
        height = int(screen.height() * 0.32)  # 32% of screen height
        x = 0
        y = screen.height() - height
        self.setGeometry(x, y, width, height)

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
            self.keyboard.resize_to_bottom()
            self.keyboard.show()

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

# 5. Create autostart desktop entry
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
