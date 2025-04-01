# CherryTalk - Matrix Client

![CherryTalk Logo](assets/images/app_icon.png)

A beautiful Matrix client with glassmorphism UI and end-to-end encryption.

## Features
- Secure Matrix protocol implementation
- Modern glassmorphism UI design
- End-to-end encrypted messaging
- Media attachments (images/files)
- Cross-platform support (Android/iOS/Web)
- User profile management
- Room creation and management

## Requirements
- Flutter 3.0+
- Dart 2.17+
- Android SDK / Xcode (for mobile builds)

## Installation
```bash
# Clone repository
git clone https://github.com/yourusername/cherrytalk.git
cd cherrytalk

# Install dependencies
flutter pub get

# Run in debug mode
flutter run
```

## Building for Production
```bash
# Android
flutter build apk --release --split-per-abi

# iOS (macOS only)
flutter build ios --release --no-codesign

# Web
flutter build web --release
```

## Configuration
1. Set default homeserver in `lib/services/matrix_service.dart`
2. Configure app icons in `pubspec.yaml`
3. Update app metadata in `pubspec.yaml`

## Screenshots
| Login Screen | Chat Screen | Profile |
|--------------|-------------|---------|
| ![Login](screenshots/login.png) | ![Chat](screenshots/chat.png) | ![Profile](screenshots/profile.png) |

## License
MIT License