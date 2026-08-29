#!/bin/bash
#
# build_dmg.sh – Erstellt aus den Swift-Quellen die App "MuTTY.app"
# und verpackt sie als signierbare .dmg (MuTTY.dmg).
#
# AUSSCHLIESSLICH UNTER macOS LAUFFÄHIG (benötigt Xcode / Command Line Tools).
# Auf dieser Linux-Umgebung kann keine .dmg erzeugt werden – deshalb dieses
# Skript bitte auf dem Mac ausführen.
#
#   cd MuTTY
#   ./build_dmg.sh
#
set -euo pipefail

APP_NAME="MuTTY"
BUNDLE_ID="com.herbstleyd.mutty"
MIN_MACOS="14.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR/Sources"
BUILD_DIR="$SCRIPT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"
DMG_PATH="$SCRIPT_DIR/$APP_NAME.dmg"

# --- Plattform-Prüfung -------------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
  echo "FEHLER: Dieses Skript muss unter macOS ausgeführt werden." >&2
  echo "        Auf dieser Maschine ($(uname)) kann keine .dmg erzeugt werden." >&2
  echo "        Bitte den Projektordner auf einen Mac kopieren und dort ausführen." >&2
  exit 1
fi

if ! command -v swiftc >/dev/null 2>&1; then
  echo "FEHLER: 'swiftc' wurde nicht gefunden." >&2
  echo "        Xcode Command Line Tools installieren:" >&2
  echo "          xcode-select --install" >&2
  exit 1
fi

SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null || true)"
ARCH="$(uname -m)"
TARGET_TRIPLE="$ARCH-apple-macosx$MIN_MACOS"

echo "▸ Plattform: macOS ($(sw_vers -productVersion 2>/dev/null || echo '?')), Arch: $ARCH"
echo "▸ SDK: ${SDK_PATH:-<Standard-SDK>}"
echo "▸ Ziel: $APP_NAME.app  →  $DMG_PATH"
echo

# --- Aufräumen ---------------------------------------------------------------
rm -rf "$BUILD_DIR"
rm -f "$DMG_PATH"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# --- Kompilieren -------------------------------------------------------------
echo "▸ Kompiliere Swift-Quellen …"
SWIFT_ARGS=(-parse-as-library -O)
if [[ -n "$SDK_PATH" ]]; then
  SWIFT_ARGS+=(-sdk "$SDK_PATH")
fi
SWIFT_ARGS+=(-target "$TARGET_TRIPLE")
SWIFT_ARGS+=("$SOURCES_DIR"/*.swift)
SWIFT_ARGS+=(-o "$MACOS_DIR/$APP_NAME")

swiftc "${SWIFT_ARGS[@]}"

# --- Info.plist --------------------------------------------------------------
echo "▸ Schreibe Info.plist …"
cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MIN_MACOS}</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>MuTTY – SSH-Profilverwaltung</string>
    <key>LSRequiresCarbon</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>MuTTY öffnet SSH-Verbindungen in Terminal.app.</string>
</dict>
</plist>
PLIST

# PkgInfo (8 Bytes: 'APPL????')
printf 'APPL????' > "$CONTENTS/PkgInfo"

# --- App-Icon (Best-Effort) --------------------------------------------------
# Versucht aus AppIcon.png ein .icns zu erzeugen. Schlägt das fehl, läuft
# die App trotzdem (nur ohne eigenes Icon).
make_icon() {
  local src="$SCRIPT_DIR/AppIcon.png"
  [[ -f "$src" ]] || { echo "  (kein AppIcon.png vorhanden – überspringe Icon)"; return 0; }
  command -v iconutil >/dev/null 2>&1 || { echo "  (iconutil nicht verfügbar – überspringe Icon)"; return 0; }
  command -v sips >/dev/null 2>&1 || { echo "  (sips nicht verfügbar – überspringe Icon)"; return 0; }

  local iconset="$BUILD_DIR/AppIcon.iconset"
  rm -rf "$iconset"
  mkdir -p "$iconset"
  sips -z 16 16   "$src" --out "$iconset/icon_16x16.png"        >/dev/null 2>&1 || true
  sips -z 32 32   "$src" --out "$iconset/icon_16x16@2x.png"     >/dev/null 2>&1 || true
  sips -z 32 32   "$src" --out "$iconset/icon_32x32.png"        >/dev/null 2>&1 || true
  sips -z 64 64   "$src" --out "$iconset/icon_32x32@2x.png"     >/dev/null 2>&1 || true
  sips -z 128 128 "$src" --out "$iconset/icon_128x128.png"      >/dev/null 2>&1 || true
  sips -z 256 256 "$src" --out "$iconset/icon_128x128@2x.png"   >/dev/null 2>&1 || true
  sips -z 256 256 "$src" --out "$iconset/icon_256x256.png"      >/dev/null 2>&1 || true
  sips -z 512 512 "$src" --out "$iconset/icon_256x256@2x.png"   >/dev/null 2>&1 || true
  sips -z 512 512 "$src" --out "$iconset/icon_512x512.png"      >/dev/null 2>&1 || true
  sips -z 1024 1024 "$src" --out "$iconset/icon_512x512@2x.png" >/dev/null 2>&1 || true

  if iconutil -c icns "$iconset" -o "$RESOURCES_DIR/AppIcon.icns" >/dev/null 2>&1; then
    echo "  App-Icon erstellt."
  else
    echo "  (Icon-Erstellung fehlgeschlagen – App läuft ohne eigenes Icon)"
  fi
}

echo "▸ Erstelle App-Icon …"
make_icon || true

# Code-Signatur (ad-hoc, damit Gatekeeper die lokal gebaute App nicht blockiert)
if command -v codesign >/dev/null 2>&1; then
  echo "▸ Signiere App (ad-hoc) …"
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
fi

# --- .dmg erzeugen -----------------------------------------------------------
echo "▸ Erstelle .dmg …"
STAGING="$BUILD_DIR/dmg_staging"
mkdir -p "$STAGING"
cp -R "$APP_DIR" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create -volname "$APP_NAME" \
  -srcfolder "$STAGING" \
  -ov -format UDZO \
  "$DMG_PATH" >/dev/null 2>&1

echo
echo "✔ FERTIG"
echo "  App:  $APP_DIR"
echo "  DMG:  $DMG_PATH"
echo
echo "  Öffnen:  open \"$DMG_PATH\""
echo "  Installieren:  MuTTY.app in den Programme-Ordner ziehen."
