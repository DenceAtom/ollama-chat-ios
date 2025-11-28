#!/bin/bash
# Build IPA script for macOS
# Run this on any Mac (even borrowed/cloud Mac)

set -e

echo "Building OllamaChat IPA..."

cd "$(dirname "$0")"

# Clean previous builds
echo "Cleaning..."
rm -rf build
mkdir -p build

# Archive
echo "Archiving..."
xcodebuild archive \
  -project OllamaChat.xcodeproj \
  -scheme OllamaChat \
  -configuration Release \
  -archivePath ./build/OllamaChat.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=""

# Export IPA
echo "Exporting IPA..."
xcodebuild -exportArchive \
  -archivePath ./build/OllamaChat.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist exportOptions.plist \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

echo ""
echo "✅ IPA built successfully!"
echo "📦 Location: ./build/OllamaChat.ipa"
echo ""
echo "Next steps:"
echo "1. Transfer the IPA to your Windows machine"
echo "2. Use AltStore, Sideloadly, or similar tool to install on iPhone"
echo ""

