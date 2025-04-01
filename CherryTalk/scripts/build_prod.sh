#!/bin/bash

# Clean and get dependencies
flutter clean
flutter pub get

# Build Android
echo "Building Android release..."
flutter build apk --release --split-per-abi
echo "Android APKs built at: build/app/outputs/flutter-apk/"

# Build iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Building iOS release..."
  flutter build ios --release --no-codesign
  echo "iOS build completed at: build/ios/Release-iphoneos/"
else
  echo "Skipping iOS build - requires macOS"
fi

# Build Web
echo "Building Web release..."
flutter build web --release
echo "Web build completed at: build/web/"

echo "Production builds completed successfully"