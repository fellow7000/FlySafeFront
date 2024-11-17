import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Generic/allowed_actions_dto.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';
import 'package:go_router/go_router.dart';

import '../Core/Vars/enums.dart';
import '../Core/Vars/globals.dart';
import '../Core/Vars/providers.dart';

class IdentityHelper {
  static void signUp() {}

  static void toSignIn(BuildContext context, WidgetRef ref, LogAs logAs) {
    ref.read(toSignAsProvider.notifier).state = logAs;
    context.go('/login');

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => LogIn(
    //               loadingLabel: "${"Loading".tr()} ${"ListedClubs".tr()}",
    //               selectClubHint: "SelectClub".tr(),
    //               formTitle: "AppTitle".tr(),
    //               logInLabel: "LogIn".tr(),
    //               closeLabel: "Close".tr(),
    //               orLabel: "Or".tr(),
    //               toPublicClubLogInLabel: "ToPublicClubLogin".tr(),
    //               userFieldLabel: "LoginCredential".tr(),
    //               toUserOrPrivateClubLogInLabel: "ToUserOrPrivateClubLogin".tr(),
    //               userNameOrEmailOrClubNameLabel: "UsernameEmailOrClub".tr(),
    //               passwordLabel: "Password".tr(),
    //               forgotPasswordLabel: "ForgotPassword".tr(),
    //               dontHaveAccountLabel: "DoNotHaveAccount".tr(),
    //               signInLabel: "SignIn".tr(),
    //               signUpLabel: "SignUp".tr(),
    //               itsFreeLabel: "ItsFree".tr(),
    //               forgotPasswordHeader: "ForgotPassword".tr(),
    //               forgotPasswordHint: "ForgotPasswordHint".tr(),
    //               enterEmailLabel: "Email".tr(),
    //               emailHint: "Email".tr(),
    //               emailLabel: "EnterEmail".tr(),
    //               resetLabel: "Reset".tr(),
    //               fieldIsRequiredLabel: "FieldIsRequired".tr(),
    //               resetPasswordConfirmationLabel: "ResetPasswordConfirmation".tr(),
    //               dataLoadErrorLabel: "BackEndComError".tr(),
    //               tapToRetryHint: appPlatform == EndDevice.web?"ClickToRetry".tr():"TapToRetry".tr(),
    //             )));
  }

  static void forgotUserPassword() {}

  static void processSignInUpResponse({required WidgetRef ref, required String loginName, required String hash, required String token, required LogAs logAs}) {
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.loggedAsPref, prefValue: logAs.name);
    ref.read(userOrClubNameProvider.notifier).state = loginName;
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.userOrClubNamePref, prefValue: loginName);
    if (hash.isNotEmpty) {
      ref.read(userOrClubHashProvider.notifier).state = hash;
      PreferencesHelper.setStringPref(prefName: PreferencesHelper.userOrClubHashPref, prefValue: hash);
    }
    accessToken = token;
    ref.read(authStateProvider.notifier).state = logAs;
  }

  static void processUserPasswordChange({required WidgetRef ref, required String newHash, required String newToken}) {
    if (newHash.isNotEmpty) {
      ref.read(userOrClubHashProvider.notifier).state = newHash;
      PreferencesHelper.setStringPref(prefName: PreferencesHelper.userOrClubHashPref, prefValue: newHash);
    }
    accessToken = newToken;
  }

  static void processSignOut({required WidgetRef ref}) {
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.loggedAsPref, prefValue: LogAs.none.name);
    ref.read(userOrClubNameProvider.notifier).state = "";
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.userOrClubNamePref, prefValue: "");
    ref.read(userOrClubHashProvider.notifier).state = "";
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.userOrClubHashPref, prefValue: "");
    accessToken = "";
    ref.read(authStateProvider.notifier).state = LogAs.none;
    requestStartUpSignIn = true;
    //TODO: invalidate provider for main form?..
  }

  static bool isActionAllowed({required AppAction appAction, required AllowedActionsDTO allowedActions}) {
    return allowedActions.allowedActions.contains(appAction.name.toUpperCase());
  }
}
