# Smart Calculator App - Project Notes

## App Info
- Name: Smart Calculator - EMI, SIP, FD
- Package: com.vasim1234.smartcalculator
- Version: 1.0.1+4
- GitHub: github.com/vasim1234/calculator.emi

## Status
- ✅ Indus Appstore pe Published (22/09/2026)
- ✅ eKYC Complete
- ✅ Release Keystore Setup Complete
- ✅ v1.0.1+4 Build Ready (Locker update)

## Files
- main.dart: smart_calculator/lib/main.dart
- pubspec.yaml: smart_calculator/pubspec.yaml
- build.gradle.kts: smart_calculator/android/app/build.gradle.kts
- MainActivity.kt: smart_calculator/android/app/src/main/kotlin/com/vasim1234/smartcalculator/MainActivity.kt
- locker_utils.dart: smart_calculator/lib/locker_utils.dart
- locker_screen.dart: smart_calculator/lib/locker_screen.dart
- AndroidManifest.xml: smart_calculator/android/app/src/main/AndroidManifest.xml
- build.yml: .github/workflows/build.yml

## Features
- Calculator (live preview + percentage)
- EMI + PDF
- SIP + PDF
- FD + PDF
- GST + PDF
- BMI + PDF
- Currency (3-layer cache)
- Age, Date, Unit Converter
- WhatsApp Share
- Dark theme
- 🔐 **Private Notes Locker** (PIN protected)
- 🔓 **Forgot PIN** (security question)
- 👆 **Biometric unlock**

## Release Keystore Info
- Keystore File: upload-keystore.jks
- Keystore Password: Vashim@123
- Key Alias: upload
- Key Password: Vashim@123
- ⚠️ Backup: Google Drive → Smart Calculator Backup

## GitHub Secrets (4)
- KEYSTORE_BASE64
- KEYSTORE_PASSWORD
- KEY_ALIAS
- KEY_PASSWORD

## Key Learnings
- Package name unique hona chahiye
- Version bump karna padta hai har upload pe
- MainActivity.kt ka package bhi change karna padta hai
- build.gradle.kts mein release signing config add karni hai
- GitHub Secrets mein keystore base64 store karni hai
- build.yml mein Flutter version pin nahi karni (latest use karo)

## Next Steps
- v1.0.1+4 ko Indus Appstore pe update karo
- Users feedback lo
- Bhai Bhai Music app bhi complete karo
- Play Store pe bhi daalo

## Contact
- Email: vashimaiyub@gmail.com
- Phone: 9904178658
