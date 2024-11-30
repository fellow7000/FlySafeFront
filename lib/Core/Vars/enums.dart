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

///AppResultCode Section Start
enum AppResultCode {
  ok,
  unauthorized,
  notFound,
  forbidden,
  conflict,
  unknown
}

Map<AppResultCode, int> _resultCodes = {
  AppResultCode.ok: 200,
  AppResultCode.unauthorized: 401,
  AppResultCode.forbidden: 403,
  AppResultCode.notFound: 404,
  AppResultCode.conflict: 409,
  AppResultCode.unknown: 999
};

int getAppResultCode(AppResultCode code) {
  return _resultCodes[code]??-1;
}

AppResultCode getAppResultEnum(int code) {
  return _resultCodes.entries.firstWhere((entry) => entry.value == code, orElse: () => MapEntry(AppResultCode.unknown, code)).key;
}
///AppResultCode Section End

///AppActions Section Start
///The enum MUST be equal to the enum in FlySafeWeb AppAction in Enums.cs (beside of the register of the first latter to keep naming convention)
enum AppAction
{
  createClub,
  readClubBaseInfo,
  getClubMembersList,
  editClubBaseInfo,
  getClubMembers,
  changeClubPassword,
  handoverClub,
  joinClub,
  leaveClub,
  deleteClub,
  assignOwner,
  unassignOwner,
  assignManager,
  unassignManager,
  removeManager,
  inviteMember,
  removeMember,
  createChecklist,
  editChecklist,
  readChecklist,
  handoverChecklist,
  createModel,
  editModel,
  readModel,
  handoverModel,
  createAircraft,
  editAircraft,
  readAircraft,
  handoverAircraft,
}
///AppActions Section End