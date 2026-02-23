#!/bin/bash
set -euo pipefail

VERSION="${1:-0.1.0}"
APP_NAME="Container GUI"
BUNDLE_NAME="Container GUI.app"
BUILD_DIR=".build/release"
PACKAGE_DIR=".build/package"
BINARY="ContainerGUI"

echo "==> Building release binary..."
swift build -c release

echo "==> Generating app icon..."
swift scripts/generate-icon.swift "$PACKAGE_DIR"

echo "==> Creating app bundle..."
rm -rf "$PACKAGE_DIR/$BUNDLE_NAME"
mkdir -p "$PACKAGE_DIR/$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$PACKAGE_DIR/$BUNDLE_NAME/Contents/Resources"

# Copy binary
cp "$BUILD_DIR/$BINARY" "$PACKAGE_DIR/$BUNDLE_NAME/Contents/MacOS/$BINARY"

# Copy Info.plist
cp Info.plist "$PACKAGE_DIR/$BUNDLE_NAME/Contents/"

# Copy icon
if [ -f "$PACKAGE_DIR/AppIcon.icns" ]; then
    cp "$PACKAGE_DIR/AppIcon.icns" "$PACKAGE_DIR/$BUNDLE_NAME/Contents/Resources/"
    rm "$PACKAGE_DIR/AppIcon.icns"
fi

# Ad-hoc sign
echo "==> Signing app bundle (ad-hoc)..."
codesign --force --deep --sign - "$PACKAGE_DIR/$BUNDLE_NAME"

# Create zip for distribution
echo "==> Creating distribution archive..."
cd "$PACKAGE_DIR"
zip -r -y "container-gui-${VERSION}-arm64-apple-macosx.zip" "$BUNDLE_NAME"
cd - > /dev/null

ARCHIVE="$PACKAGE_DIR/container-gui-${VERSION}-arm64-apple-macosx.zip"
SHA=$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')

echo ""
echo "==> Done!"
echo "    App:     $PACKAGE_DIR/$BUNDLE_NAME"
echo "    Archive: $ARCHIVE"
echo "    SHA256:  $SHA"
