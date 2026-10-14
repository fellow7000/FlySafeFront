# Toolchain upgrade — 14 October 2026

Branch: `codex/upgrade-flutter-3.47.7-dart-3.13.5-riverpod-3.4.3-android-api37-ios-sdk27`.

## Changes

- FVM pinned to Flutter 3.47.7 / Dart 3.13.5. The previously configured 3.27.0
  symlink pointed to an SDK directory that no longer existed.
- Upgraded every direct runtime/development dependency to a current stable
  compatible release, and refreshed compatible transitive dependencies.
- Riverpod 3.4.3: legacy imports preserve existing StateProvider code; unified
  Provider types replace removed AutoDispose interfaces. Automatic retry is
  disabled in the application container because existing FutureProviders perform
  writes. Explicit refresh/retry remains available.
- The clock now emits distinct integer ticks. Riverpod 3's equality filtering
  otherwise suppresses repeated null events and prevents clock updates.
- Corrected a callback parameter declaration rejected by the current Dart
  analyzer and adopted DropdownButtonFormField.initialValue.
- Android: API 37 compile/target, API 24 minimum, AGP 9.4.0 / Gradle 9.6.0,
  Java 17, and AGP built-in Kotlin. Kotlin 2.3.20 remains declared for plugin
  compatibility. The legacy AGP DSL compatibility flag remains required by Flutter.
- Removed conflicting Android plugin declarations, obsolete manifest package
  attributes, the machine-specific Java path, and Gradle's source-file build
  counter mutation. Build name/number now come directly from Flutter's settings.
- iOS: minimum target 15.0, verified with Xcode 27 / iOS SDK 27. Flutter migrated
  the native startup to UIScene/FlutterImplicitEngineDelegate and added Swift
  Package Manager integration. Current plugins resolve through SwiftPM.
- Replaced the generated counter test with seven regression tests; added setup
  and verification instructions in README.md.

## Dependency versions

| Package | Before | Resolved after |
| --- | --- | --- |
| flutter_riverpod | 2.6.1 | 3.4.3 |
| go_router | 14.6.0 | 18.1.0 |
| http | 1.2.2 | 1.6.0 |
| web_socket_channel | 3.0.1 | 3.0.3 |
| easy_localization | 3.0.7 | 3.0.8 |
| shared_preferences | 2.3.3 | 2.5.6 |
| sqflite | 2.4.1 | 2.4.4+2 |
| url_launcher | 6.3.1 | 6.3.3 |
| package_info_plus | 8.1.1 | 10.2.2 |
| wakelock_plus | 1.2.8 | 1.8.1 |
| cupertino_icons | 1.0.8 | 2.0.0 |
| path | 1.9.0 | 1.9.1 |
| flutter_lints | 5.0.0 | 6.0.0 |
| rflutter_alert | 2.0.7 | 2.0.7 |
| date_format | 2.0.9 | 2.0.9 |

The remaining older transitive versions of material_color_utilities and test_api
are pinned by the Flutter SDK. No dependency overrides were added.

## Verification

| Check | Result |
| --- | --- |
| Standard Flutter test suite | Seven tests passed |
| Dart analysis | Zero errors; 14 warnings and 23 info messages |
| Android API 37 debug build, built-in Kotlin | Passed |
| Unsigned iOS release build, iOS SDK 27 | Passed |
| Flutter web release build | Passed; Wasm dry-run also passed |
| Release bundle in Chrome | Home, continuously updating clock, settings, language selector, and sign-in route verified |
| Git whitespace check | Passed |

The tests cover mobile startup and mode switching, wide web layout without a
Flight switch, login/registration/password-reset rendering and back navigation,
settings/localization/theme updates, saved preference compatibility, distinct
clock events, and failed sign-in with explicit rather than automatic retry.
They use fake credentials/API failures and perform no real backend writes.

## Limits and deferred work

- The standard analyzer exit remains nonzero because of existing warnings/info
  messages: unused fields/locals, unreachable switch defaults, mutable widget
  fields, missing explicit types exposed by newer lints, and an unnecessary
  qualifier. No lint rules were suppressed. To distinguish compiler failures
  from this recorded baseline, run
  `fvm flutter analyze --no-fatal-infos --no-fatal-warnings`.
- The Chrome widget-test harness stalled during translation-asset loading, even
  when preloading in setUpAll; those runs were stopped and are not counted as
  passing. The compiled release web application loaded its actual assets and was
  checked directly in Chrome. Browser integration automation remains future work.
- No physical phones or emulators were connected during verification. Native
  plugin behavior, iOS app installation, and signed distribution builds still
  need device/release validation. The iOS result is an unsigned compilation.
- Flutter doctor reports some unaccepted Android SDK licenses, although the
  installed packages required by this upgrade built successfully. No new license
  agreements were accepted automatically.
- iOS retains a supported hybrid CocoaPods/SwiftPM setup; Flutter warns that
  remaining CocoaPods integration can be removed manually. A full CocoaPods
  removal is not necessary for the verified build.
- Existing authentication, TLS-development settings, SQLite schema/migrations,
  and backend contracts were not redesigned. No database was opened/reset and
  no application data migration was run.
- Ground/Flight labels and new offline/synchronization behavior are deferred.
  Existing saved `online`/`flight` preference values are preserved by this upgrade.
- The pre-existing spreadsheet modification under `spec/` was not changed or
  included in this work. Backend files were not modified.
