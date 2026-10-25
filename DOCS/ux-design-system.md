# FlySafe Front – UX design system

Binding reference for all screens in the Flutter front end. UX/UI work (human or agent) must follow it. Generic UX rules and the verification procedure are in the `ux-design-review` skill; this file holds the FlySafe specifics.

## Reference ("mainstream") screens

Use these as the visual baseline and screenshot them before any redesign:

| Screen | Code | Pattern |
|---|---|---|
| Manage your account (user profile) | `lib/UI/Identity/Manage/user_or_club_profile.dart` | Card with ListTile rows, dividers, chevrons, full-width primary button |
| Change password | `lib/UI/Identity/Manage/change_user_password.dart`, `lib/UI/Elements/password_change_fields.dart` | Form page in BasisForm + Card, standard fields, full-width primary button |
| Delete account | `lib/UI/Identity/Manage/delete_user_account.dart` | Destructive full page: title, one warning text, confirmation, full-width red button |
| Login | `lib/UI/Identity/login.dart` | Form card |

## Layout

- Every sub-page is a `BasisForm(formTitle: ..., form: ...)` (`lib/UI/Elements/basis_form.dart`): AppBar with back arrow and title, body centred, scrollable, width `windowWidth` on small windows, `standardPanelWidth` (430) otherwise.
- Content sits in one `Card(elevation: 3)` with `Padding(all: 15)` and a `Column` of rows.
- Card title: first row, `Padding(all: 10)`, centred, `textTheme.headlineSmall` with `fontWeightDelta: 1` and `fontSizeDelta: deltaFontSize`.
- Rows are separated by `Divider(indent: 10, endIndent: 10)`.

## Rows

- Info row (read-only): `ListTile(leading: Icon(size: appIconBasisSize + delta), title: label in textStyleTitleMedium, subtitle: value in textStyleTitleLarge)`, no trailing, no onTap.
- Editable info row: same as an info row plus `trailing: Icon(chevronExpand)` and `onTap` that opens a small dialog (e.g. Club Type → radio list with one-line hints, Cancel + primary Save, Save disabled until the value changes). Show the chevron/onTap only if the server allows the edit action; otherwise render the plain info row.
- Multi-value info row (e.g. a user's roles in a club): label in singular/plural ("Role"/"Roles"), one value per line in the subtitle. Never a comma-joined string.
- Navigation row: `ListTile(leading: icon, title: text in textStyleTitleLarge, trailing: Icon(chevronExpand), onTap: push page)`.
- Destructive navigation row (e.g. Delete account): same as a navigation row, **only the leading icon** in the warning colour; the title stays in the normal text colour.
- Danger zone: destructive rows go last in the card, after a little extra space and a normal divider. No "Danger zone" header, no red divider, no red banner.
- People list (e.g. club members, `lib/UI/Clubs/club_members.dart`): one card, title = the list name, one `ListTile` per person (leading `userIcon`, title = user name, subtitle = role). Mark the current user with a small "(You)" after the name in `bodyMedium`, not a chip or colour. Chevron/onTap only on rows the server lets you act on (`AllowedRoles` non-empty or `CanRemove`); other rows are plain. The "add" entry is a navigation row at the end of the list, shown only when the server allows it. Never show emails.
- Item detail page reached from such a list (e.g. a member): card title = the item name, an editable info row for the attribute (role → radio dialog with one-line hints), then the destructive row last per "Danger zone".
- Icons come from `lib/Core/Vars/globals.dart` (`userIcon`, `clubIcon`, `passwordIcon`, `clearTextIcon`, `chevronExpand`, `logOutIcon`, ...). Add new icon constants there instead of using `Icons.*` inline.
- The identity row's leading icon (user/club name) is in `validColor*` (green); other icons use the default colour.

## Buttons

- Primary action: `SizedBox(width: double.infinity)` + `ElevatedButton`, background `primaryActionButtonDefEnabledColorLight/Dark`, label `headlineSmall` in white, inner padding 10. Optional leading white icon in a `Row`.
- Destructive action: same shape with background `primaryWarningButtonEnabledColorLight/Dark`, white label when enabled.
- Disabled: let Flutter's disabled style apply, but make sure the label stays legible in light **and** dark mode (no dark text on mid-red). A disabled **destructive** button is plain grey, never pink: `grey.shade300` + `grey.shade800` label (light), `grey.shade800` + `grey.shade300` label (dark). See `ClubStyles.destructiveButton` in `lib/UI/Clubs/club_ui.dart`.
- Dialog actions: `TextButton` for Cancel, coloured `ElevatedButton` for the confirm action, labelled with the action verb.

## Colours (`lib/UI/Themes/app_themes.dart`)

- Always pick light/dark variants via `Theme.of(context).brightness`.
- Blue `primaryActionButtonDef*`: primary actions. Green `validColor*`: identity/valid states. Red `primaryWarningButton*` / `notValidColor*`: destructive actions and errors only.
- Red text is limited to **one** warning sentence per destructive page (see Delete account) and validation errors. Explanatory text, field labels and borders stay in the default theme colours.
- Destructive full page (user decision, Delete Club): red only for the page title (bold), the warning icon (`warningIcon`) and one bold sentence `Warning! The <object> "<name>" will be deleted.` Everything else (consequences, fields, labels, borders) is in the normal text colour. The button is red when enabled, grey when disabled.
- Reversible removal (e.g. remove a member, who can be added again): confirmation dialog, no typed confirmation. Red only for the icon, the title and one warning sentence naming both objects; the consequence sentence and Cancel stay in the normal colour; confirm button red, labelled with the verb ("Remove"). See `RemoveMemberDialog` in `lib/UI/Clubs/club_member_dialogs.dart`.
- Privacy-neutral results (e.g. add a member by name or email, where the server answers the same whether or not the user exists): show a neutral snackbar ("If a user with this name or email exists, they are now a member", 4 s), never "added" or "not found".
- Red on dark surfaces: use `Colors.red.shade400` for red text/icons (the dark warning colour reads pink) and `Colors.red.shade700` for the button background.

## Typography and scaling

- Use `textStyleTitleMedium`, `textStyleTitleLarge`, `textStyleHeadlineSmall` from globals or `Theme.of(context).textTheme.*`, always applying `fontSizeDelta: ref.watch(deltaFontSizeProvider)`.
- Long labels in rows: wrap with `FittedBox(fit: BoxFit.scaleDown)` like "Club Management" in the profile screen.
- **Dark mode pitfall:** the global `textStyle*` variables are created by `AppHelper.initFonts` above `MaterialApp` and carry the light-theme text colour, so they are nearly invisible in dark mode. In new or reworked screens take styles from `Theme.of(context).textTheme` (e.g. `ClubStyles.of(context, delta)`), not from the globals.
- Input labels must fit in one line at 375 px in all three languages. Put explanations in `helperText` (with `helperMaxLines`), not in the label: a truncated label ("Your personal login password (not the …") hides exactly the important part.

## States

- Loading or processing: `AppProcessIndicator(message: "Loading".tr() / "Processing".tr())` in place of the content or button.
- Server errors: `ApiErrorMessages(callErrors: ..., deltaFontSize: ...)` directly above the action button.
- Success: `SnackBar` with a localised message, then pop and invalidate the affected providers.
- Permission gating: show rows/actions only if `IdentityHelper.isActionAllowed(appAction: ..., allowedActions: <server response>)`. The back end must not return actions that will be rejected for this user (e.g. LeaveClub for the last Owner).

## Localisation

- Every string goes through `.tr()` with keys in `assets/langs/en.json`, `de.json` and `ru.json`. Check German and Russian for overflow.

## Verification specifics

- Web debug server: http://localhost:8090 (see AGENTS.md for how it is started). API: http://localhost:5200 (`?api-version=4.0`).
- Local test users: `smokepilot` (Owner of "Smoke Club"), `lonepilot`; password `Smoke-Pass-123!`. Never really delete or leave the clubs "Smoke Club", "Race Club" or "Lone Club" while verifying; create a throwaway club if a destructive flow must be completed end to end.
- Flutter web automation: click `flt-semantics-placeholder` to enable semantics, re-read the page after each navigation, retry clicks after a short wait.
- Theme: switch via the theme toggle in the side menu (`lib/UI/Elements/MainSidePanel/theme_mode_swith.dart`). Font size: app settings.
- Widths: narrow ≈375 px (drawer layout) and wide ≥1280 px (side panel layout).
- Narrow layout: the sign-in / account entry is the icon at the right of the AppBar (≈ width−70, 28); the theme toggle is in the drawer (hamburger at 28, 28), close it with "Dismiss".
- A second club role for verification: register a throwaway user (`api/user/register`), and afterwards delete its own club (`deleteclub`) and the account (`GET api/user/deleteuserprofile`).
- Playwright on Flutter web: `fill()` does not reach Flutter inputs; click the `input`, wait ~500 ms, then `keyboard.type` (without the wait the first character is lost). Escape does not close dialogs; click Cancel.
- Several test users own a club whose name equals the user name and which has an empty club password; an empty password logs in as that club (Club Profile). Always log in with the real user password.

## Known anti-patterns (seen in the Club management screens, Oct 2026)

Don't repeat these. All eight were fixed in the Club management redesign (branch `copilot/club-manage`).

1. The card title repeats a value that is also shown as the first info row (club name twice).
2. The AppBar title is a generic word ("Club") instead of context.
3. A custom red "Danger zone" header with a red full-width divider, plus red titles on every destructive row. The design system uses only a red leading icon.
4. A destructive page where every paragraph is red, an ALL-CAPS "WARNING!" is used, and empty input fields have red borders and labels so they look invalid before any input.
5. A disabled destructive button with dark text on a pink background (low contrast); the action name appears both as the title and the button without the object name.
6. Showing "Leave club" to the only Owner, where it always fails, and only offering an alternative after the user has confirmed.
7. A bordered `DataTable` for a navigation list (Clubs Manager) instead of ListTile rows with chevrons.
8. Dialog body text in red for a simple reversible question.
