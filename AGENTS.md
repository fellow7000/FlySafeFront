# FlySafeFront — NG Flutter client

## Purpose & status
- **Active development.** New FlySafe front end (package `fs_front`, version `4.0.0+1`) for Android, iOS and web;
  `macos/`, `windows/`, `linux/` platform folders exist but are not covered by the README build/verification steps.
- Implemented: home/main screen, settings (theme, font size, language), sign-in/sign-up/password reset, account management,
  club create/join/details, local SQLite DB bootstrap, `AppMode` online/flight toggle (web is always online).
- **Not yet implemented:** checklist UI, weight & balance / CG UI, offline synchronization (deferred).

## Layout (`lib/`)
- `main.dart` — `ProviderContainer` (implicit Riverpod retry disabled), EasyLocalization, `MaterialApp.router`.
- `Core/` — `DTO/` (Base, Club, Generic, Identity), `Entities/`, `Vars/` (`globals.dart`, `providers.dart`, `routes.dart`, `enums.dart`).
- `Infrastructure/BackEnd/` — `backend_call.dart` + `IdentityCalls/`, `ClubCalls/`, `GenericCalls/`; `Infrastructure/LocalDB/` (sqflite).
- `Helpers/` — app/identity/preferences helpers, `http_overrider.dart`.
- `Mock/` — mock back-end implementations for identity and club calls (currently unused; see DOCS/frontend-review-2026.md).
- `UI/` — `MainScreen`, `Identity`, `Clubs`, `Settings`, `LocalDB`, `Elements`, `Themes` (Material 3 light/dark).
- `assets/langs/{en,de,ru}.json`, `assets/images/`; `test/` (+ `test/support/app_harness.dart`).
- `DOCS/toolchain-upgrade-3.47.7.md`, `DOCS/Prompts/` (WebSocket refactor notes), `spec/fs_front_fnctions.xlsx` (function spec).

## Toolchain & versions
- Flutter **3.47.7 pinned via FVM** (`.fvmrc`); Dart 3.13.5 (`sdk: ^3.13.5`). Always use `fvm flutter ...`.
- flutter_riverpod 3.4.3 (23 files still import `flutter_riverpod/legacy.dart` for `StateProvider`), go_router 18.1.0,
  http, web_socket_channel, sqflite, shared_preferences, easy_localization, flutter_lints 6.
- Android: compile/target API 37, min API 24, AGP 9.4.0 / Gradle 9.6.0, Java 17, NDK 28.2.13676358.
- iOS: min 15.0, Xcode 27; SwiftPM plugins + CocoaPods for the engine.
- `pubspec.lock` is committed and must stay committed.

## Commands (repo root)
```sh
fvm install
fvm use 3.47.7 --skip-pub-get
fvm flutter pub get
fvm flutter analyze --no-fatal-infos --no-fatal-warnings   # baseline: 0 errors, 0 warnings, 23 infos
fvm flutter test                                           # VM tests; do not use the Chrome test harness (stalls)
fvm flutter run -d chrome
fvm flutter build web --release
fvm flutter build apk --debug
fvm flutter build ios --release --no-codesign
```
- Plain `fvm flutter analyze` exits non-zero because of the recorded baseline; do not add new warnings.
- Web release bundle is deployed by copying `build/web` into `../FlySafeWeb/FlySafeWeb.API/wwwroot/app`
  (procedure in `../FlySafeWeb/Docs/Backend/ProjectHints.md`). Verify the release bundle in a real browser.

## Configuration & secrets
- Backend hosts (prod, dev, `localhost:5200`) are defined in `lib/Core/Vars/globals.dart` (`webHosts`); selected via `webHostProvider`.
- Android release signing: git-ignored `android/key.properties` + existing upload keystore; SDK path in ignored `android/local.properties`.
  Never commit them and never substitute debug signing for a production release.
- Debug builds install `HttpOverrider` (accepts any TLS certificate). Keep it debug-only.

## Conventions observed in code
- REST calls go through `BackEndCall`: URI `/api/{controller}/{handler}` built by `AppHelper.generateUri`
  (controller constants such as `api/user`, `api/club` in `Infrastructure/BackEnd/*/i_api_*.dart`),
  headers `x-version: 4.0`, `Content-Type: application/json`, `Accept-Language`, `Authorization` bearer; 60 s timeout.
  Error codes mapped to `CallError` (200/400/401/409, `-1` = exception).
- State: Riverpod providers centralized in `lib/Core/Vars/providers.dart`; routing in `lib/Core/Vars/routes.dart` (go_router).
- Strings via easy_localization keys (`"Key".tr()`); add every new key to all three `assets/langs/*.json`.
- File names snake_case, directories PascalCase. Line length 150 (`settings.json`). Lints: `flutter_lints` (`analysis_options.yaml`).
- Existing preference keys, app identifiers, auth contract and local DB schema must be preserved (see README "Upgrade scope").

## Known state, gaps & TODO hotspots
- `lib/Infrastructure/LocalDB/local_db.dart`: `dbVersion = 5`; upgrades `updateDB2toDB3`, `updateDB3toDB4`, `updateDB4toDB5`
  are `TODO` and throw `UnimplementedError`. sqflite has no web/Windows/Linux backend in the current dependencies.
- Many screens have `//TODO: implementation of error handling is open!` (`UI/Identity/*`, `UI/Clubs/*`).
- `AppHelper.exitApp()` does not work on iOS (`UI/Elements/Dialogs/*`).
- Hard-coded labels marked `//TODO: replace with code label` (settings, account pages).
- Ground/Flight terminology change and browser integration tests are deferred (see `DOCS/toolchain-upgrade-3.47.7.md`).

## Related repos
- `../FlySafeWeb` — NG .NET 10 backend this app calls (API version 4.0).
- `../../FS_Original/ios_fsf` — legacy Flutter app: reference for checklist and W&B/CG logic and UX (reference only).
- `../../FS_Original/FlySafeWebGH` — legacy backend (reference only).

Cross-repo team context lives in the workspace root AGENTS.md (/FS_Proj); start agents from the workspace root for multi-repo work.
Overall FlySafe NG product and project documentation lives in `../FlySafeWeb/Docs/`; frontend-specific documentation belongs in `DOCS/`.
