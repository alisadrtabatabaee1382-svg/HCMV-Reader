\
@echo off
setlocal
echo == Flutter deps ==
flutter pub get
if not exist android (
  echo == Creating platforms ==
  flutter create .
)
echo == Building APK (debug) ==
flutter build apk --debug
echo APK at build\app\outputs\flutter-apk\app-debug.apk
