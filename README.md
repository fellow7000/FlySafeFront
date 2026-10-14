# FlySafe! frontend

Flutter application for Android, iOS, and web. Application version: 4.0.0.

## Toolchain

| Component | Version |
| --- | --- |
| Flutter (FVM) | 3.47.7 |
| Dart (bundled with Flutter) | 3.13.5 |
| Riverpod | 3.4.3 |
| Android compile/target SDK | API 37 |
| Android minimum SDK | API 24 (Android 7) |
| Android Gradle Plugin / Gradle | 9.4.0 / 9.6.0 |
| Kotlin compatibility plugin declaration | 2.3.20; Android modules use AGP built-in Kotlin |
| Java | 17 |
| Xcode / iOS SDK verified | 27.0 / 27.0 |
| iOS minimum deployment target | 15.0 |

The Flutter version is pinned in `.fvmrc`. Commit `pubspec.lock` so developers
resolve the same dependency versions. Dart comes with Flutter; a separate Dart
installation is not required.

## Setup

Install [FVM](https://fvm.app/documentation/getting-started/installation), then run:

```sh
fvm install
fvm use 3.47.7 --skip-pub-get
fvm flutter pub get
fvm flutter doctor -v
```

Android builds require the Android API 37 platform, SDK command-line/build tools,
NDK 28.2.13676358, and Java 17. Configure the SDK through Android Studio and keep
machine-specific SDK paths in the ignored `android/local.properties`. Flutter
uses its configured JDK; the repository no longer hardcodes one Mac's Java path.

iOS builds require macOS and Xcode 27. This project uses Swift Package Manager
for the current plugins and retains CocoaPods integration for the Flutter engine
(CocoaPods 1.16.2 was verified). Flutter generates the package files during builds.

## Run and verify

```sh
fvm flutter run -d chrome
fvm flutter test
fvm flutter analyze
fvm flutter build web --release
fvm flutter build apk --debug
fvm flutter build ios --release --no-codesign
```

The widget tests use the Flutter VM asset loader and exercise phone and web
presentation variants. Check the release web bundle in a browser as well; the
Chrome widget harness currently stalls loading the bundled translation assets.

The existing analyzer warnings are documented in
[the toolchain upgrade report](DOCS/toolchain-upgrade-3.47.7.md).

Android release signing still uses the ignored `android/key.properties` and the
existing upload keystore. Never substitute debug signing for a production release.
iOS distribution also requires the existing signing identity and provisioning.

## Upgrade scope

This upgrade preserves the existing functionality, preference keys, application
identifiers, authentication contract, and local database schema/data. Ground/Flight
terminology and behavior, architecture changes, security work, synchronization,
notes, and timestamps are separate follow-up work.
