enum AppBuild { alpha, closedBeta, publicBeta, releaseCandidate, release }

enum EndDevice {android, ios, windows, linux, macos, fuchsia, web, other, unknown}

enum AppThemeMode {light, dark, system}

enum DateTimeType {loc, utc}
enum DateTimeOrder {timeDate, dateTime}

enum WindowWidth {small, mid, large} //application window, NOT a device screen
enum WindowHeight {small, mid, large} //application window, NOT a device screen

enum AppMode { online, flight } //Mobile app can run in either of modes, web is always in Online

enum AppLanguage {autoLanguage, english, deutsch, russian}

enum ClubType
{
  globalCatalog,
  publicClub,
  nonListedClub,
}

enum ClubCreateMode
{
  createAndAssign,
  createOnly
}

enum LogAs {
  none,
  user,
  userOrClub,
  club,
  signUp,
  forgotPassword,
  failed,
}

enum PasswordType {
  plainText,
  hash
}

enum AppFormState {
  connectingToHost,
  dataInput,
  processing,
  resultOk,
  resultFailed,
  httpError,
  exception
}

enum CallTypeAPI {
  get,
  post
}

enum ValidationStatus {
  init,
  validating,
  ok,
  notValid,
  failed
}

enum ValidationType {
  field,
  email
}

enum UserRole {
  admin,
  clubOwner,
  clubManager,
  clubMember,
  unknown
}

//keep index!
enum NoteType {
  folder,
  note
}