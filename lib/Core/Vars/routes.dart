import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Helpers/app_helper.dart';
import '../../UI/Identity/login.dart';
import '../../UI/MainScreen/main_screen.dart';
import 'enums.dart';
import 'globals.dart';

final appRouter = GoRouter(
  // Define your application's routes here
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return GestureDetector(
              onTap: () => AppHelper.dismissKeyboard(context),
              child: const SafeArea(child: MainScreen()));
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return LogIn(
                loadingLabel: "${"Loading".tr()} ${"ListedClubs".tr()}",
                selectClubHint: "SelectClub".tr(),
                formTitle: "AppTitle".tr(),
                logInLabel: "LogIn".tr(),
                closeLabel: "Close".tr(),
                orLabel: "Or".tr(),
                toPublicClubLogInLabel: "ToPublicClubLogin".tr(),
                userFieldLabel: "LoginCredential".tr(),
                toUserOrPrivateClubLogInLabel: "ToUserOrPrivateClubLogin".tr(),
                userNameOrEmailOrClubNameLabel: "UsernameEmailOrClub".tr(),
                passwordLabel: "Password".tr(),
                forgotPasswordLabel: "ForgotPassword".tr(),
                dontHaveAccountLabel: "DoNotHaveAccount".tr(),
                signInLabel: "SignIn".tr(),
                signUpLabel: "SignUp".tr(),
                itsFreeLabel: "ItsFree".tr(),
                forgotPasswordHeader: "ForgotPassword".tr(),
                forgotPasswordHint: "ForgotPasswordHint".tr(),
                enterEmailLabel: "Email".tr(),
                emailHint: "Email".tr(),
                emailLabel: "EnterEmail".tr(),
                resetLabel: "Reset".tr(),
                fieldIsRequiredLabel: "FieldIsRequired".tr(),
                resetPasswordConfirmationLabel: "ResetPasswordConfirmation".tr(),
                dataLoadErrorLabel: "BackEndComError".tr(),
                tapToRetryHint: clickToRetry.tr(),
              );
            },
          )])
  ],
);