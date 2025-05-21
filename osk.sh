#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!]${NC} Please run as root (sudo)"
    exit 1
fi

# Get the current user
CURRENT_USER=$SUDO_USER
HOME_DIR="/home/$CURRENT_USER"

print_status "Installing On-Screen Keyboard RU/EN"

# Create extension directory
CHROME_DIR="$HOME_DIR/chrome-linux"
EXTENSION_DIR="$CHROME_DIR/extensions"
EXTENSION_ID="on-screen-keyboard-ru-en"

mkdir -p "$EXTENSION_DIR/$EXTENSION_ID/src"
mkdir -p "$EXTENSION_DIR/$EXTENSION_ID/styles"
mkdir -p "$EXTENSION_DIR/$EXTENSION_ID/assets"

# Create manifest.json
cat > "$EXTENSION_DIR/$EXTENSION_ID/manifest.json" << 'EOL'
{
  "manifest_version": 3,
  "name": "On-Screen Keyboard RU/EN",
  "version": "1.0",
  "description": "A modern on-screen keyboard with Russian and English layouts",
  "permissions": [
    "activeTab",
    "storage"
  ],
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["src/content.js"],
      "css": ["styles/keyboard.css"]
    }
  ],
  "background": {
    "service_worker": "src/background.js"
  }
}
EOL

# Create content.js
cat > "$EXTENSION_DIR/$EXTENSION_ID/src/content.js" << 'EOL'
const keyboardLayouts = {
  en: {
    default: [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.'],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', '123', '🌐', '↓']
    ],
    shift: [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.'],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', '123', '🌐', '↓']
    ],
    symbols: [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '=', '_', '+', '{', '}', '[', ']', '(', ')'],
      ['!', '@', '#', '$', '%', '^', '&', '*', '|', '\\'],
      ['/', '<', '>', ',', '.', '~', '`'],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', 'ABC', '🌐', '↓']
    ]
  },
  ru: {
    default: [
      ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
      ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
      ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '.', ','],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', '123', '🌐', '↓']
    ],
    shift: [
      ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
      ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
      ['Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '.', ','],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', '123', '🌐', '↓']
    ],
    symbols: [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '=', '_', '+', '{', '}', '[', ']', '(', ')'],
      ['!', '@', '#', '$', '%', '^', '&', '*', '|', '\\'],
      ['/', '<', '>', ',', '.', '~', '`'],
      ['SHIFT', 'ENTER', 'BACKSPACE', 'SPACE', 'ABC', '🌐', '↓']
    ]
  }
};

class OnScreenKeyboard {
  constructor() {
    this.currentLayout = 'en';
    this.isShifted = false;
    this.isSymbols = false;
    this.isVisible = false;
    this.activeElement = null;
    this.init();
  }

  init() {
    this.createKeyboard();
    this.createFloatingButton();
    this.addEventListeners();
  }

  createKeyboard() {
    const container = document.createElement('div');
    container.className = 'keyboard-container';
    container.id = 'osk-container';
    document.body.appendChild(container);
    this.updateKeyboardLayout();
  }

  createFloatingButton() {
    const button = document.createElement('button');
    button.className = 'floating-button';
    button.innerHTML = '⌨️';
    button.id = 'osk-toggle';
    document.body.appendChild(button);
  }

  updateKeyboardLayout() {
    const container = document.getElementById('osk-container');
    container.innerHTML = '';

    const layout = this.isSymbols 
      ? keyboardLayouts[this.currentLayout].symbols
      : this.isShifted 
        ? keyboardLayouts[this.currentLayout].shift 
        : keyboardLayouts[this.currentLayout].default;

    layout.forEach(row => {
      const rowDiv = document.createElement('div');
      rowDiv.className = 'keyboard-row';
      
      row.forEach(key => {
        const keyButton = document.createElement('button');
        keyButton.className = 'key';
        keyButton.textContent = key;
        
        if (key === 'SPACE') keyButton.className += ' space';
        if (key === 'SHIFT') keyButton.className += ' shift';
        if (key === 'ENTER') keyButton.className += ' enter';
        if (key === 'BACKSPACE') keyButton.className += ' backspace';
        if (key === '🌐') keyButton.className += ' lang-switch';
        if (key === '123' || key === 'ABC') keyButton.className += ' symbol-switch';
        if (key === '↓') keyButton.className += ' hide-keyboard';
        
        keyButton.addEventListener('click', () => this.handleKeyPress(key));
        rowDiv.appendChild(keyButton);
      });
      
      container.appendChild(rowDiv);
    });
  }

  handleKeyPress(key) {
    if (!this.activeElement) return;

    switch (key) {
      case 'SHIFT':
        this.isShifted = !this.isShifted;
        this.updateKeyboardLayout();
        break;
      case 'ENTER':
        this.activeElement.value += '\n';
        break;
      case 'BACKSPACE':
        this.activeElement.value = this.activeElement.value.slice(0, -1);
        break;
      case 'SPACE':
        this.activeElement.value += ' ';
        break;
      case '🌐':
        this.currentLayout = this.currentLayout === 'en' ? 'ru' : 'en';
        this.updateKeyboardLayout();
        break;
      case '123':
      case 'ABC':
        this.isSymbols = !this.isSymbols;
        this.updateKeyboardLayout();
        break;
      case '↓':
        this.hideKeyboard();
        break;
      default:
        this.activeElement.value += key;
        if (this.isShifted && !this.isSymbols) {
          this.isShifted = false;
          this.updateKeyboardLayout();
        }
    }

    this.activeElement.dispatchEvent(new Event('input', { bubbles: true }));
  }

  showKeyboard(element) {
    this.activeElement = element;
    const container = document.getElementById('osk-container');
    container.classList.add('visible');
    this.isVisible = true;
  }

  hideKeyboard() {
    const container = document.getElementById('osk-container');
    container.classList.remove('visible');
    this.isVisible = false;
    this.activeElement = null;
  }

  addEventListeners() {
    document.addEventListener('focusin', (e) => {
      if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
        this.showKeyboard(e.target);
      }
    });

    document.getElementById('osk-toggle').addEventListener('click', () => {
      if (this.isVisible) {
        this.hideKeyboard();
      } else {
        const activeElement = document.activeElement;
        if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
          this.showKeyboard(activeElement);
        }
      }
    });

    document.addEventListener('click', (e) => {
      if (!e.target.closest('.keyboard-container') && 
          !e.target.closest('.floating-button') && 
          e.target.tagName !== 'INPUT' && 
          e.target.tagName !== 'TEXTAREA') {
        this.hideKeyboard();
      }
    });
  }
}

// Initialize the keyboard
new OnScreenKeyboard();
EOL

# Create background.js
cat > "$EXTENSION_DIR/$EXTENSION_ID/src/background.js" << 'EOL'
chrome.runtime.onInstalled.addListener(() => {
  console.log('On-Screen Keyboard RU/EN extension installed');
});

// Listen for messages from content script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'KEYBOARD_STATE') {
    // Handle keyboard state changes if needed
    sendResponse({ success: true });
  }
});
EOL

# Create keyboard.css
cat > "$EXTENSION_DIR/$EXTENSION_ID/styles/keyboard.css" << 'EOL'
.keyboard-container {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  background: #ffffff;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.15);
  padding: 10px;
  z-index: 999999;
  display: none;
  font-family: 'Roboto', sans-serif;
  box-sizing: border-box;
}

.keyboard-container.visible {
  display: block;
}

.keyboard-row {
  display: flex;
  justify-content: center;
  margin: 5px 0;
  width: 100%;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.key {
  min-width: 40px;
  height: 40px;
  margin: 3px;
  border: none;
  border-radius: 5px;
  background: #f0f0f0;
  color: #333;
  font-size: 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  user-select: none;
  flex: 1;
  max-width: 60px;
}

.key:hover {
  background: #e0e0e0;
}

.key:active {
  background: #d0d0d0;
  transform: scale(0.95);
}

.key.special {
  background: #e0e0e0;
  font-weight: bold;
}

.key.space {
  flex: 4;
  max-width: 300px;
}

.key.shift {
  flex: 2;
  max-width: 120px;
}

.key.enter {
  flex: 2;
  max-width: 120px;
}

.key.backspace {
  flex: 2;
  max-width: 120px;
}

.key.lang-switch {
  flex: 1.5;
  max-width: 90px;
}

.key.symbol-switch {
  flex: 1.5;
  max-width: 90px;
}

.key.hide-keyboard {
  flex: 1.5;
  max-width: 90px;
}

.floating-button {
  position: fixed;
  bottom: 20px;
  right: 20px;
  width: 50px;
  height: 50px;
  border-radius: 25px;
  background: #2196F3;
  color: white;
  border: none;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000000;
  transition: all 0.3s ease;
}

.floating-button:hover {
  background: #1976D2;
  transform: scale(1.05);
}

.floating-button:active {
  transform: scale(0.95);
}

.floating-button i {
  font-size: 24px;
}

/* Media queries for different screen sizes */
@media screen and (min-width: 1920px) {
  .key {
    min-width: 50px;
    height: 50px;
    font-size: 20px;
  }
  
  .keyboard-row {
    max-width: 1600px;
  }
}

@media screen and (min-width: 2560px) {
  .key {
    min-width: 60px;
    height: 60px;
    font-size: 24px;
  }
  
  .keyboard-row {
    max-width: 2000px;
  }
}

@media screen and (min-width: 3840px) {
  .key {
    min-width: 70px;
    height: 70px;
    font-size: 28px;
  }
  
  .keyboard-row {
    max-width: 2400px;
  }
}
EOL

# Set permissions
chown -R $CURRENT_USER:$CURRENT_USER "$EXTENSION_DIR/$EXTENSION_ID"
chmod -R 755 "$EXTENSION_DIR/$EXTENSION_ID"

# Create autostart with command line flags
AUTOSTART_DIR="$HOME_DIR/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/chrome-extension-autostart.desktop" << EOL
[Desktop Entry]
Type=Application
Name=On-Screen Keyboard RU/EN
Exec=chromium --enable-features=ExtensionsToolbarMenu --load-extension="$EXTENSION_DIR/$EXTENSION_ID" --enable-extensions
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

chown $CURRENT_USER:$CURRENT_USER "$AUTOSTART_DIR/chrome-extension-autostart.desktop"
chmod 644 "$AUTOSTART_DIR/chrome-extension-autostart.desktop"

# Kill existing Chromium processes
pkill chromium || true

# Start Chromium with the extension
su - $CURRENT_USER -c "chromium --enable-features=ExtensionsToolbarMenu --load-extension=\"$EXTENSION_DIR/$EXTENSION_ID\" --enable-extensions &"

print_status "Installation completed! The keyboard should be working now." 
