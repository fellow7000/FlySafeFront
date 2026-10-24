# FlySafeFront – Front-End Review (refactor & architecture)

Scope: `lib/` and `test/` of FlySafeFront at `b187a76` (Flutter 3.47.7, Dart 3.13.5, flutter_riverpod 3.4.3),
compared with `FlySafeWeb/Docs/architecture/architecture-principles.md`, `architecture.md` and `technology-stack.md`.
Roles: tech lead (architecture), frontend developer (code), QA (tests). Authentication / token / credential storage is
**out of scope** here: the current implementation is historical and will be redesigned in a dedicated session (see §5).

Branch with low-hanging fixes: `copilot/frontend-review-quick-fixes` (local, not pushed).

## 1. Summary

| Check                                                                 | Before (`b187a76`) | After quick fixes |
|-----------------------------------------------------------------------|--------------------|-------------------|
| `fvm flutter analyze --no-fatal-infos --no-fatal-warnings` (err/warn/info) | 0 / 14 / 23        | 0 / 0 / 23        |
| `fvm flutter test`                                                     | 7 passed           | 9 passed          |
| Line coverage (`flutter test --coverage`)                              | 25.9 %             | not re-measured   |

The refactor is **incomplete and mixed**: Riverpod 3 / go_router / easy_localization were adopted mechanically, but the
old patterns (legacy `StateProvider` state, `Navigator.push`, mutable globals, providers declared inside widgets and DTOs,
command pattern via `StateProvider` + `FutureProvider`) remain the dominant style. There are no Notifiers at all.
The layering `UI / Core / Infrastructure / Helpers` exists as folders but is not enforced (UI and DTOs call
infrastructure providers directly, DTO files declare providers).

## 2. Findings

Severity: **H** high, **M** medium, **L** low. Status: **Fixed** = fixed on the quick-fix branch, **Open** = still to do,
**Auth** = deferred to the authentication session.

### 2.1 Correctness / behaviour

| #  | Sev | Location | Finding | Status / recommendation |
|----|-----|----------|---------|-------------------------|
| 1  | H | `lib/UI/Clubs/club_details.dart` | Access check was inverted (club name/actions shown when `readClubBaseInfo` was *not* allowed); a null `club` crashed. | **Fixed**: shows `NoAccessToClub` when club is null or action not allowed. |
| 2  | H | `lib/UI/Clubs/club_details.dart` | Members / Delete buttons called methods that `throw UnimplementedError` → crash on tap. | **Fixed**: buttons disabled (`onPressed: null`) until implemented. |
| 3  | M | `lib/Infrastructure/BackEnd/ClubCalls/api_club.dart` | Backend returns 403 with `Club == null` for missing ReadClubBaseInfo; client treated it as a generic exception. | **Fixed**: 403 → `Forbidden()` (rendered as `AccessDenied` by `ApiErrorTileRetry`). 404 still a generic exception – Open (L). |
| 4  | H | `lib/UI/Clubs/add_club.dart` ↔ FlySafeWeb `CheckClubNameFree` | Club-name validation contract is broken across repos: client parses a bare `bool` from `checkvaluesocket`, no time-stamp echo, so stale answers can overwrite newer input; REST `checkclubnamefree` returns a bare bool through `ReturnCode`. | **Open** (needs backend + client change): one contract `{isValid, timeStamp}` or a debounced REST call; drop the WebSocket unless required. |
| 5  | M | `lib/UI/Clubs/add_club.dart` | WebSocket lifecycle: `late` channel disposed before init → `LateInitializationError`; "connected" flag set before connection; no reconnect wait; stale channel callbacks after dispose. | **Fixed** (hardening): nullable channel, `await ready` with timeout, stale-channel guard, `mounted` checks, failure shows `ValidationError`. Full redesign tied to #4. |
| 6  | M | `lib/UI/Clubs/add_club.dart`, `join_club.dart` | Async `then/onError` wrote to autoDispose providers after the widget could be disposed (throws in Riverpod 3). | **Fixed**: `mounted` guards. Real fix: Mutations (§4). |
| 7  | H | `lib/Infrastructure/LocalDB/local_db.dart` | DB migrations `4→5` are empty stubs. The legacy store app (`FS_Original/ios_fsf`) uses the same app ID `fellow7000.aviacheck`, DB file `fsf.db` and `dbVersion = 4` → an in-place store update would run an empty migration and break the DB. Creation inserts were not awaited. | Creation **Fixed** (awaited, empty commands skipped); stubs now throw a descriptive error. **Open – release blocker**: implement and test `4→5` migration (with a v4 fixture DB). |
| 8  | M | `lib/Helpers/preferences_helper.dart` | Fragile preference parsing (`firstWhere` without `orElse`, `byName` on stale values, list identity for date format) → crash on corrupted/legacy values; debug log printed preference values. | **Fixed** + 2 tests. |
| 9  | M | `lib/Core/Vars/providers.dart` | `backEndUser` / `backEndGeneric` captured the host once via `ref.read(...notifier).state` → host switch ignored. | **Fixed**: `ref.watch(webHostProvider)`. Note: host switch now rebuilds dependants (intended). |
| 10 | L | `lib/UI/Identity/login_user_or_club.dart:173` | `value:` → `initialValue:` (b187a76) on the public-club dropdown: no longer follows provider changes. | **Open**: use a keyed field or controlled value. |
| 11 | L | `lib/UI/Identity/Manage/delete_user_account.dart:142` | `GlobalKey<FormState>()` created in `build()` → form state lost on every rebuild. | **Open**: hold the key in State. |
| 12 | L | `lib/UI/MainScreen/main_screen.dart:68`, `lib/UI/Identity/login.dart:182` | Host switch (prod/dev/localhost) reachable in release after 5 hidden taps. | **Open**: compile-time flavour (`--dart-define`) instead of runtime switch in store builds. |
| 13 | L | `lib/UI/Identity/sign_up.dart:665` | Form is never validated before submit (TODO). | **Open**. |
| 14 | L | `lib/Core/Vars/globals.dart:9` | `appBuildE = AppBuild.alpha` constant must be edited manually for production. | **Open**: `--dart-define` / flavours. |

### 2.2 Architecture / maintainability

| #  | Sev | Location | Finding | Recommendation |
|----|-----|----------|---------|----------------|
| 15 | M | 23 files import `flutter_riverpod/legacy.dart`; 0 Notifiers | State is held in `StateProvider`s (legacy, discouraged in Riverpod 3). | Migrate to `Notifier` / `AsyncNotifier` (§4). |
| 16 | M | ~89 providers declared inside widgets / DTO files (e.g. `club_details_response.dart:37`), 31 in `providers.dart` | Instance-field providers in widgets create a new provider per widget instance; non-autoDispose ones leak. DTO files depend on infrastructure. | Providers per feature in `features/<x>/application/`; DTOs pure. |
| 17 | M | `lib/Core/Vars/globals.dart:11,19,37` | Mutable globals (`accessToken`, `isMobileDevice`, `hostClicks`). | Move into providers (token → auth session). |
| 18 | M | Navigation | go_router (`routes.dart`) and 12 `Navigator.push` calls are mixed. | Route all screens through go_router; typed routes. |
| 19 | M | Error handling | `CallError` lists, `AppFormState` enums and exceptions coexist; `_callErrors` in widgets partially unused/TODO. | One `Result`/`AppFailure` type in the API layer, mapped once to UI messages. |
| 20 | L | `lib/Mock/` | Mock back-ends exist but are unused (tests hit no fake). | Either use them as test overrides (`IApiClub` override) or delete. |
| 21 | L | `assets/langs/*.json` | Key names diverged between en/de/ru (`Longtitude`, `Sunrise`, `GlbClbPswMsg`, missing keys). | **Fixed**: identical key sets (546). Open: add a test asserting identical key sets. |
| 22 | L | analyzer | 14 warnings (unused fields/locals, `must_be_immutable`, unreachable `default`, dead socket constant). | **Fixed**: 0 warnings. Open: 23 infos; add `riverpod_lint`. |

### 2.3 Tests (QA)

- 9 widget/unit tests, ≈26 % line coverage; no tests for API client error mapping, LocalDB creation/migration, club flows
  or navigation guards.
- Priorities: (1) LocalDB v4→v5 migration with fixture, (2) `ApiClub` status-code mapping with a fake `http.Client`,
  (3) club details access states (allowed / forbidden / not found), (4) preferences round-trip, (5) l10n key parity.
- Use `ProviderContainer.test()` and `overrideWithBuild` / `overrideWithValue` instead of the custom harness where possible.

## 3. Target architecture

Feature-first, layered inside each feature, aligned with the documented principles (clear boundaries, testability,
offline-capable clients):

```
lib/
  app/            # bootstrap, ProviderScope, router (go_router), theme, l10n setup, flavours
  core/           # cross-cutting: result/failure types, http client, logging, storage abstractions
  features/
    clubs/
      data/         # DTOs (pure, json), ClubApi (http), ClubLocalStore
      domain/       # entities, repository interface (optional, only where logic exists)
      application/  # Notifiers / AsyncNotifiers / Mutations (Riverpod)
      presentation/ # widgets, screens – no http, no DTO providers
    identity/ ...
    settings/ ...
```

Rules: presentation → application → data; DTO files never declare providers; one error type crossing layers;
host/flavour from `--dart-define`; secrets only through the auth module (separate session).

## 4. Riverpod 3 – is the upgrade using it?

**Answer: no.** The migration to 3.x was mechanical (imports switched to `legacy.dart`, `value:`→`initialValue:` etc.).
None of the 3.x improvements are used. Concrete improvements available:

| Riverpod 3 feature | Current code | Improvement |
|--------------------|--------------|-------------|
| `Notifier` / `AsyncNotifier` (unified autoDispose/family) | `StateProvider` everywhere | Encapsulated state + methods; testable without widgets. |
| **Mutations** (`Mutation<T>()`, `mutation.run(ref, …)`, idle/pending/error/success) – experimental | "request `StateProvider` + `FutureProvider` + `ref.watch(x.future)` in a callback" for every submit (add/join club, sign up, change e-mail/password, delete account) | Replaces the command pattern; no disposal mid-request; built-in pending/error state for spinners. |
| `Ref.mounted` | none; crashes avoided by ad-hoc `mounted` checks | Guard async work inside notifiers. |
| Family via constructor args | `clubDetailsRequestProvider` set before reading `clubDetailsProvider` | `ClubDetailsNotifier(clubId)` – no hidden ordering dependency. |
| Automatic retry | disabled globally (`retry: (_, __) => null`) | Enable per read-only provider (club list, profile) with backoff; keep off for commands. |
| `ProviderException` wrapping of `ref.read(x.future)` / `requireValue` | `ApiErrorTileRetry` works because it uses `.when(error:)`; code awaiting `.future` and checking `is Unauthorised` would break | Unwrap or check `.exception`; prefer `AsyncValue` in UI. |
| `updateShouldNotify` uses `==` | DTOs do not implement `==` | Add `==`/`hashCode` (or `freezed`) for DTOs held in state, to avoid redundant rebuilds. |
| Listeners pause off-screen | n/a | Free gain, nothing to do. |
| Offline persistence (`persist()`, `riverpod_sqflite`) – experimental | own `sqflite` LocalDB + SharedPreferences | Option for the offline ADR (cache club list / settings); evaluate, do not adopt blindly while experimental. |
| Testing: `ProviderContainer.test`, `overrideWithBuild`, `WidgetTester.container` | custom `createAppContainer` harness | Simpler, auto-disposed test containers. |
| `riverpod_lint` (+ optional `riverpod_generator`) | not configured | Catches missing `ref.mounted`, provider-in-widget, etc. |

Before / after for a submit flow (sketch):

```dart
// Before (add_club.dart)
ref.read(addClubRequestProvider.notifier).state = AddClubRequest(...);
ref.watch(addClubProvider.future).then((data) { ... }).onError((e, s) { ... });

// After
final addClubMutation = Mutation<AddClubResponse>();

Future<void> submit(WidgetRef ref, AddClubRequest request) =>
    addClubMutation.run(ref, (tsx) async {
      final api = tsx.get(clubApiProvider);
      final result = await api.createClub(request);
      ref.invalidate(userProfileProvider);
      return result;
    });

// UI
final state = ref.watch(addClubMutation);
switch (state) {
  MutationPending() => const CircularProgressIndicator(),
  MutationError(:final error) => ErrorText(error),
  _ => SubmitButton(onPressed: () => submit(ref, request)),
}
```

Migration order: (1) add `riverpod_lint`; (2) move providers out of DTOs/widgets into feature `application/`;
(3) settings & host → `Notifier`s; (4) read queries → `AsyncNotifier`/family with per-provider retry;
(5) submit flows → Mutations (start with clubs); (6) remove `legacy.dart` imports; (7) tests on `ProviderContainer.test`.

## 5. Deferred to the authentication session

- Password hash stored in SharedPreferences (`preferences_helper.dart:24,71-87`) and re-used as credential (pass-the-hash).
- Access token in a mutable global (`globals.dart:37`); no secure storage, no refresh-token flow.
- Sign-in side effects inside `build()` (`main_screen.dart:83-85`).
- Login submit flow without error handling for some paths (`login_user_or_club.dart`).
- Leave / hand-over club placeholders (hand-over is out of app scope – FSAdmin only).

## 6. Phased plan

1. **Stabilise** (done on quick-fix branch): crashes, warnings, prefs hardening, l10n parity.
2. **Release blockers**: LocalDB v4→v5 migration + tests; club-name validation contract (backend + client); flavours instead of host switch.
3. **Auth redesign** (separate session).
4. **Riverpod 3 adoption** per §4, feature by feature (clubs first).
5. **Structure**: feature-first folders, go_router only, unified error type.
6. **Quality gates**: `riverpod_lint`, analyzer infos to 0, coverage target ≥ 60 % for application/data layers.
