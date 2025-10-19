#!/usr/bin/env bash
set -e
echo "== Flutter deps =="
flutter pub get
if [ ! -d "android" ] || [ ! -d "ios" ]; then
  echo "== Creating platform folders =="
  flutter create .
fi
echo "== Building Android APK (release) =="
flutter build apk --release
echo "== Building Android AppBundle (release) =="
flutter build appbundle --release
echo "== Building iOS (release, no codesign) =="
flutter build ios --release --no-codesign
echo "== Done =="
echo "Artifacts:"
echo "  - build/app/outputs/flutter-apk/app-release.apk"
echo "  - build/app/outputs/bundle/release/app-release.aab"
echo "  - build/ios/iphoneos/Runner.app (archive-ready)"
