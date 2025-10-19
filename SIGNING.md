# راهنمای امضا و گرفتن خروجی نصب برای iOS و Android

## Android (APK/AAB)
- برای **APK بدون امضای انتشار**، ورک‌فلو `Android Release` کافی‌ست (APK ریلیز ساخته می‌شود؛ برای انتشار در پلی‌استور AAB لازم است).
- برای امضای ریلیز، این Secrets را در GitHub تنظیم کنید:
  - `ANDROID_KEYSTORE_BASE64`  ← محتوای keystore تبدیل‌شده به Base64
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_PASSWORD`
  - `ANDROID_KEY_ALIAS`

## iOS (IPA)
- نیاز به حساب **Apple Developer** و پروفایل provisioning دارید.
- Secrets لازم:
  - `APPLE_TEAM_ID`  ← شناسه تیم
  - `APPLE_BUNDLE_ID` ← مثل com.example.hcmvreader
  - `IOS_SIGNING_CERT_P12_BASE64`  ← گواهی امضا (p12) به صورت Base64
  - `IOS_SIGNING_CERT_PASSWORD`
  - `IOS_MOBILEPROVISION_BASE64`  ← فایل provisioning *.mobileprovision* به صورت Base64
- سپس ورک‌فلو `iOS Signed IPA` را اجرا کنید؛ Artifact خروجی: فایل **.ipa** قابل نصب (Ad-Hoc/TestFlight).

## ساخت محلی (بدون CI)
- macOS:
  ```bash
  ./scripts/build_all.sh
  ```
- Windows (فقط اندروید دیباگ):
  ```bat
  scripts\build_android_debug.bat
  ```
