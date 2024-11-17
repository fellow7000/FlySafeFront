import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/UI/Elements/toggle_host.dart';
import 'package:fs_front/UI/Identity/Elements/to_sign_up_panel.dart';
import 'package:fs_front/UI/Identity/login_user_or_club.dart';
import 'package:fs_front/UI/Identity/request_password_reset.dart';
import 'package:fs_front/UI/Identity/sign_up.dart';

import '../../Core/Vars/enums.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';
import '../Themes/app_themes.dart';

class LogIn extends ConsumerWidget {
  final String loadingLabel;
  final String selectClubHint;
  final String formTitle;
  final String logInLabel;
  final String closeLabel;
  final String orLabel;
  final String toPublicClubLogInLabel;
  final String userFieldLabel;
  final String toUserOrPrivateClubLogInLabel;
  final String userNameOrEmailOrClubNameLabel;
  final String passwordLabel;
  final String forgotPasswordLabel;
  final String dontHaveAccountLabel;
  final String signInLabel;
  final String signUpLabel;
  final String itsFreeLabel;
  final String forgotPasswordHeader;
  final String forgotPasswordHint;
  final String enterEmailLabel;
  final String emailHint;
  final String emailLabel;
  final String resetLabel;
  final String fieldIsRequiredLabel;
  final String resetPasswordConfirmationLabel;
  final String dataLoadErrorLabel;
  final String tapToRetryHint;

  const LogIn({
    super.key,
    required this.loadingLabel,
    required this.selectClubHint,
    required this.formTitle,
    required this.logInLabel,
    required this.closeLabel,
    required this.orLabel,
    required this.toPublicClubLogInLabel,
    required this.userFieldLabel,
    required  this.toUserOrPrivateClubLogInLabel,
    required this.userNameOrEmailOrClubNameLabel,
    required this.passwordLabel,
    required this.forgotPasswordLabel,
    required this.dontHaveAccountLabel,
    required this.signInLabel,
    required this.signUpLabel,
    required this.itsFreeLabel,
    required this.forgotPasswordHeader,
    required this.forgotPasswordHint,
    required this.enterEmailLabel,
    required this.emailHint,
    required this.emailLabel,
    required this.resetLabel,
    required this.fieldIsRequiredLabel,
    required this.resetPasswordConfirmationLabel,
    required this.dataLoadErrorLabel,
    required this.tapToRetryHint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color appBarIconColor = Theme.of(context).brightness == Brightness.light ? appBarIconColorLight : appBarIconColorDark;

    //orientation build is needed to prevent framework error on orientation change
    return OrientationBuilder(builder: (context, orientation) {

      Widget logInWidget;
      Widget footerWidget = ToSignUpOrIn(haveAccountLabel: dontHaveAccountLabel, signUpInLabel: signUpLabel, itsFreeLabel: itsFreeLabel, toggleUpIn: () => _toSignUp(ref),);

        switch (ref.watch(toSignAsProvider)) {
        case LogAs.userOrClub:
          logInWidget = LogInUserOrClub(
            selectClubHint: selectClubHint,
            logInLabel: logInLabel,
            closeLabel: closeLabel,
            orLabel: orLabel,
            toggleLoginTypeLabel: toPublicClubLogInLabel,
            userFieldLabel: userFieldLabel,
            userNameOrEmailOrClubNameLabel: userNameOrEmailOrClubNameLabel,
            passwordLabel: passwordLabel,
            forgotPasswordLabel: forgotPasswordLabel,
            dontHaveAccountLabel: dontHaveAccountLabel,
            signUpLabel: signUpLabel,
            itsFreeLabel: itsFreeLabel,
            fieldIsRequiredLabel: fieldIsRequiredLabel);
          break;

        case LogAs.club:
          logInWidget = ref.watch(publicClubsProvider).when(
              loading: () => AppProcessIndicator(message: loadingLabel),
              skipLoadingOnRefresh: false,
              error : (err, stack) => ApiErrorTileRetry(
                err: err,
                errorMessage: dataLoadErrorLabel,
                errorStack: stack,
                tapToRetryHint: tapToRetryHint,
                deltaSize: ref.watch(deltaFontSizeProvider),
                retryCallBack: () => reloadPublicClubs(ref),
              ),
              data: (clubs) => LogInUserOrClub(
                  publicClubs: clubs,
                  selectClubHint: selectClubHint,
                  logInLabel: logInLabel,
                  closeLabel: closeLabel,
                  orLabel: orLabel,
                  toggleLoginTypeLabel: toUserOrPrivateClubLogInLabel,
                  userFieldLabel: userFieldLabel,
                  userNameOrEmailOrClubNameLabel: userNameOrEmailOrClubNameLabel,
                  passwordLabel: passwordLabel,
                  forgotPasswordLabel: forgotPasswordLabel,
                  dontHaveAccountLabel: dontHaveAccountLabel,
                  signUpLabel: signUpLabel,
                  itsFreeLabel: itsFreeLabel,
                  fieldIsRequiredLabel: fieldIsRequiredLabel)
          );
          break;

        case LogAs.forgotPassword:
          logInWidget = RequestPasswordReset(
              forgotPasswordHeader: forgotPasswordHeader,
              forgotPasswordHint: forgotPasswordHint,
              enterEmailLabel: enterEmailLabel,
              emailHint: emailHint,
              emailLabel: emailLabel,
              resetLabel: resetLabel,
              logInLabel: logInLabel,
              orLabel: orLabel,
              fieldIsRequiredLabel: fieldIsRequiredLabel,
              resetPasswordConfirmationLabel: resetPasswordConfirmationLabel);
          break;

        case LogAs.signUp:
          footerWidget = ToSignUpOrIn(haveAccountLabel: "HaveAccount".tr(), signUpInLabel: "SignIn".tr(), toggleUpIn: () => _toSignIn(ref),);
          logInWidget = const SignUp();
        break;

        default:
          logInWidget = Container(); //just a place holder, default shall never been reached!
        break;
      }

      return SafeArea(
        child: GestureDetector(
          onTap: () => AppHelper.dismissKeyboard(context),
          child: Scaffold(
            key: scaffoldKeySignIn,
            appBar: AppBar(
              title: Text(formTitle),
              leading: IconButton(icon: const Icon(Icons.arrow_back), color: appBarIconColor, onPressed: () => Navigator.pop(context, false)),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: winWidth == WindowWidth.small?windowWidth : standardPanelWidth,
                  child: Column(
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: logInWidget,
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      footerWidget,
                      const Padding(padding: EdgeInsets.only(top: 20), child: ToggleHost())
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      });
  }
  
  void reloadPublicClubs(WidgetRef ref) {
    return ref.refresh(publicClubsProvider);
  }

  void _toSignUp(WidgetRef ref) {
    ref.read(toSignAsProvider.notifier).state = LogAs.signUp;
  }

  void _toSignIn(WidgetRef ref) {
    ref.read(toSignAsProvider.notifier).state = LogAs.userOrClub;
  }
}