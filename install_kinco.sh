#!/bin/bash

# === Variables ===
DOWNLOAD_URL="https://cdownload.kinco.cn/Download/software/HMI/Kinco%20DTools%20V4.5.0.1%20Build250106%EF%BC%88250106%EF%BC%89en.zip"
ZIP_NAME="Kinco_DTools.zip"
INSTALL_DIR="$HOME/.wine/drive_c/Kinco/Kinco_DTools"
APP_DIR="$HOME/Applications/Kinco"
WINEPREFIX="$HOME/.wine"
LINKS_ONLY=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--links-only) LINKS_ONLY=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if Wine directory exists when using --links-only
if [ "$LINKS_ONLY" = true ] && [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ Error: Kinco DTools directory not found at $INSTALL_DIR"
    echo "Please install Kinco DTools first or use this script without --links-only"
    exit 1
fi

if [ "$LINKS_ONLY" = false ]; then
    echo "🚀 Starting Kinco DTools installation..."

    # === Step 1: Download the Kinco DTools archive ===
    echo "📥 Downloading Kinco DTools..."
    curl -L "$DOWNLOAD_URL" -o "$ZIP_NAME"

    # === Step 2: Extract the archive ===
    echo "📦 Extracting archive..."
    unzip -q "$ZIP_NAME" -d "Kinco_DTools_Extracted"
    rm "$ZIP_NAME"

    # === Step 3: Install Wine and Winetricks ===
    echo "🍷 Installing Wine and Winetricks..."
    arch -x86_64 brew install --cask wine-stable
    arch -x86_64 brew install winetricks

    # === Step 4: Copy the extracted files to Wine ===
    echo "📁 Copying files to Wine prefix..."
    mkdir -p "$INSTALL_DIR"
    cp -R Kinco_DTools_Extracted/* "$INSTALL_DIR"
    rm -rf Kinco_DTools_Extracted

    # === Step 5: Install required libraries with winetricks ===
    echo "🔧 Installing required DLLs..."
    arch -x86_64 winetricks -q mfc42 msxml3 msxml6 cjkfonts
else
    echo "🔗 Creating application shortcuts only..."
fi

# === Step 6: Create macOS .app wrappers ===
mkdir -p "$APP_DIR"

function create_app() {
    APP_NAME="$1"
    EXE_PATH="$2"
    APP_PATH="$APP_DIR/$APP_NAME.app"

    echo "📎 Creating shortcut: $APP_NAME"

    mkdir -p "$APP_PATH/Contents/MacOS"
    mkdir -p "$APP_PATH/Contents/Resources"

    cat > "$APP_PATH/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>app</string>
</dict>
</plist>
EOF

    # Create launcher script
    cat > "$APP_PATH/Contents/MacOS/$APP_NAME" <<EOF
#!/bin/bash
export WINEDEBUG=-all
export WINEPREFIX="$HOME/.wine"
export PATH="/usr/local/bin:/opt/homebrew/bin:\$PATH"
cd "$HOME"
WINE_PATH=\$(which wine)
if [ -z "\$WINE_PATH" ]; then
    osascript -e 'display notification "Wine is not installed" with title "Error" subtitle "Please install Wine using Homebrew"'
    exit 1
fi
exec "\$WINE_PATH" "$EXE_PATH"
EOF
    chmod +x "$APP_PATH/Contents/MacOS/$APP_NAME"

    # Extract icon from EXE
    echo "🎨 Extracting icon from $EXE_PATH..."
    TMP_ICON_DIR=$(mktemp -d)
    wrestool -x -t14 -o "$TMP_ICON_DIR" "$EXE_PATH"
    ICO_FILE=$(find "$TMP_ICON_DIR" -name "*.ico" | head -n 1)

    if [ -f "$ICO_FILE" ]; then
        magick convert "$ICO_FILE[0]" "$TMP_ICON_DIR/icon.png"
        mkdir -p "$TMP_ICON_DIR/icon.iconset"
        sips -z 16 16     "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_16x16.png" >/dev/null
        sips -z 32 32     "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_16x16@2x.png" >/dev/null
        sips -z 32 32     "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_32x32.png" >/dev/null
        sips -z 64 64     "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_32x32@2x.png" >/dev/null
        sips -z 128 128   "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_128x128.png" >/dev/null
        sips -z 256 256   "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_128x128@2x.png" >/dev/null
        sips -z 256 256   "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_256x256.png" >/dev/null
        sips -z 512 512   "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_256x256@2x.png" >/dev/null
        sips -z 512 512   "$TMP_ICON_DIR/icon.png" --out "$TMP_ICON_DIR/icon.iconset/icon_512x512.png" >/dev/null
        cp "$TMP_ICON_DIR/icon.png" "$TMP_ICON_DIR/icon.iconset/icon_512x512@2x.png"

        iconutil -c icns "$TMP_ICON_DIR/icon.iconset" -o "$APP_PATH/Contents/Resources/app.icns"
    else
        echo "⚠️  Icon extraction failed; using default icon."
    fi

    rm -rf "$TMP_ICON_DIR"
}

create_app "Kinco DTools" "$INSTALL_DIR/Kinco DTools.exe" "$INSTALL_DIR/Kinco DTools.ico"
create_app "KDManager" "$INSTALL_DIR/KDManager.exe" "$INSTALL_DIR/KDManager.ico"

echo "✅ Installation complete! Shortcuts created in: $APP_DIR"
