import 'package:easy_localization/easy_localization.dart';

import '../Core/DTO/Base/call_error.dart';

//Error codes of the club management calls. The names are equal to the back end's ErrorCodes and the translation keys.
class ClubErrorCodes {
  static const String lastOwnerCannotLeave = "LastOwnerCannotLeave";
  static const String userPasswordMismatch = "UserPasswordMismatch";
  static const String clubNameConfirmationMismatch = "ClubNameConfirmationMismatch";
  static const String otherOwnersMustApprove = "OtherOwnersMustApprove";
  static const String cannotChangeOwnMembership = "CannotChangeOwnMembership";
  static const String memberRankTooHigh = "MemberRankTooHigh";
  static const String lastOwnerCannotBeRemoved = "LastOwnerCannotBeRemoved";
  static const String userNotMember = "UserNotMember";
  static const String actionNotAllowed = "ActionNotAllowed";
  //app-side codes for HTTP errors of the member calls that have no body
  static const String memberInputInvalid = "MemberInputInvalid";
  static const String memberRequestInvalid = "MemberRequestInvalid";
  static const String clubNotFound = "ClubNotFound";
  static const String tooManyAttempts = "TooManyAttempts";

  static const List<String> localized = [
    lastOwnerCannotLeave,
    userPasswordMismatch,
    clubNameConfirmationMismatch,
    otherOwnersMustApprove,
    cannotChangeOwnMembership,
    memberRankTooHigh,
    lastOwnerCannotBeRemoved,
    userNotMember,
    actionNotAllowed,
    memberInputInvalid,
    memberRequestInvalid,
    clubNotFound,
    tooManyAttempts,
  ];
}

class ClubErrorHelper {
  static bool hasCode(List<CallError> errors, String code) => errors.any((e) => e.code == code);

  //marks the known codes as app-translated, so they are shown in the user's language
  static List<CallError> localize(List<CallError> errors) {
    return errors
        .map((e) => ClubErrorCodes.localized.contains(e.code) ? CallError(code: e.code, description: e.description, localError: true) : e)
        .toList();
  }

  static String message(List<CallError> errors) {
    if (errors.isEmpty) return "BackEndComError".tr();
    final e = errors.first;
    return ClubErrorCodes.localized.contains(e.code) ? e.code.tr() : e.description;
  }
}
