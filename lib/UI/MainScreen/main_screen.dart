import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/UI/Elements/MainSidePanel/app_mode_toggle.dart';
import 'package:fs_front/UI/Elements/toggle_host.dart';
import 'package:fs_front/UI/MainScreen/side_main_menu.dart';

import '../../Core/DTO/Identity/authentification_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Elements/Dialogs/exit_dialog.dart';
import '../Elements/MainSidePanel/sign_in_tile.dart';
import '../Elements/Dialogs/start_dialog.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenWgt();
}

class MainScreenWgt extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();

    if (!kIsWeb &&
        !kDebugMode &&
        ref.read(isShowStartDialogProvider.notifier).state) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          StartDialog().startDialog(
              context: context,
              ref: ref,
              title: "${"Warning".tr()}!",
              dialogText:
                  "${"AppAboutTxt".tr()}\n\n${"ContinueConfirmation".tr()}",
              showWarningLabel: "ShowWarningAtStart".tr(),
              continueLabel: "Continue".tr(),
              exitLabel: "Exit".tr());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    globalRef = ref;
    globalContext = context;
    windowWidth = MediaQuery.of(context).size.width; //get the shortest side
    windowHeight = MediaQuery.of(context).size.height; //get the longest side
    winWidth = AppHelper.getWindowWidth(windowWidth);

    List<Widget> widgetList = [
      Text(
          "Width: ${windowWidth.toStringAsFixed(0)}, Height: ${windowHeight.toStringAsFixed(0)}\nWindow width: ${winWidth.toString()}\nPlatform: ${appPlatform.name}\nSinged in as: ${ref.watch(authStateProvider.notifier).state.toString()}\nApp Mode: ${ref.watch(appModeProvider)}",
          textAlign: TextAlign.center),
      Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Text(ref.watch(dateTimeLocProvider));
      }),
      const ToggleHost()
    ];

    Widget mainScreen = Container();

    debugPrint("Request start-up sign in: $requestStartUpSignIn");

    //authorize if needed
    if (ref.watch(isStartConfirmedProvider) &&
        ref.watch(appModeProvider) == AppMode.online &&
        (ref.watch(authStateProvider) == LogAs.user ||
            ref.watch(authStateProvider) == LogAs.club) &&
        requestStartUpSignIn) {
      //sigInProvider is prepared during preference initialization

      mainScreen = ref.watch(signInProvider).when(
          data: (response) {
            accessToken = response.accessToken;

            // List<Widget> widgetList = [
            //   Text("Width: ${windowWidth.toStringAsFixed(0)}, Height: ${windowHeight.toStringAsFixed(0)}\nWindow width: ${winWidth.toString()}\nPlatform: ${appPlatform.name}\nSinged in as: ${ref.watch(authStateProvider.notifier).state.toString()}", textAlign: TextAlign.center),
            //   Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
            //       return Text(ref.watch(dateTimeLocProvider));
            //   }),
            //   const ToggleHost()
            // ];
            requestStartUpSignIn = false;

            return MainPanel(widgetList: widgetList);
          },
          error: (err, stack) => MainPanel(widgetList: [
                ApiErrorTileRetry(
                  err: err,
                  errorMessage: "BackEndComError".tr(),
                  errorStack: stack,
                  tapToRetryHint: clickToRetry.tr(),
                  deltaSize: ref.watch(deltaFontSizeProvider),
                  retryCallBack: () => _retryConnectionToAuthorize(ref),
                )
              ]),
          loading: () => MainPanel(
              widgetList: [AppProcessIndicator(message: "SigningIn".tr())]));
    } else if (ref.watch(isStartConfirmedProvider)) {
      mainScreen = MainPanel(widgetList: widgetList);
    }

    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool shouldPop = await ExitDialog.exitConfirmation(
            context: context,
            ref: ref,
            title: "Confirm".tr(),
            dialogText: "AppExitText".tr(),
            noLabel: "No".tr(),
            yesLabel: "Yes".tr());
        if (shouldPop) {
          // Since this is the root route, quit the app where possible by
          // invoking the SystemNavigator. If this wasn't the root route,
          // then Navigator.maybePop could be used instead.
          // See https://github.com/flutter/flutter/issues/11490
          navigator.pop();
        }
      },

      // onPopInvokedWithResult: (didPop) async {
      //   if (didPop) {
      //     return;
      //   }
      //   final NavigatorState navigator = Navigator.of(context);
      //   final bool shouldPop = await ExitDialog.exitConfirmation(
      //       context: context,
      //       ref: ref,
      //       title: "Confirm".tr(),
      //       dialogText: "AppExitText".tr(),
      //       noLabel: "No".tr(),
      //       yesLabel: "Yes".tr());
      //   if (shouldPop) {
      //     navigator.pop();
      //   }
      // },
      // onPopInvokedWithResult: (bool didPop) { ExitDialog.exitConfirmation(
      //     context: context,
      //     ref: ref,
      //     title: "Confirm".tr(),
      //     dialogText: "AppExitText".tr(),
      //     noLabel: "No".tr(),
      //     yesLabel: "Yes".tr());},
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit: BoxFit.scaleDown, child: Text("AppTitle".tr())),
          centerTitle: false,
          actions: [
            if (isMobileDevice && winWidth != WindowWidth.large)
              AppModeToggle(
                  onLineModeLabel: "Online".tr(),
                  flightModeLabel: "FlightMode".tr()),
            if (winWidth != WindowWidth.large)
              SignInTile(
                signInLabel: "SignIn".tr(),
                userOrClubName: ref.watch(userOrClubNameProvider),
              ),
            if (winWidth != WindowWidth.large) const SizedBox(width: 50)
          ],
        ),
        body: (ref.watch(isStartConfirmedProvider))
            ? SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    if (winWidth == WindowWidth.large)
                      const Align(
                          alignment: Alignment.topCenter,
                          child: SideMainMenu()),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          mainScreen
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     Text("Width: ${windowWidth.toStringAsFixed(0)}, Height: ${windowHeight.toStringAsFixed(0)}\nWindow width: ${winWidth.toString()}\nPlatform: ${appPlatform.name}\nSinged in as: ${ref.watch(authStateProvider.notifier).state.toString()}", textAlign: TextAlign.center),
                          //     Text(ref.watch(dateTimeLocProvider)),
                          //     const ToggleHost()
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        drawer: winWidth == WindowWidth.large ? null : _leftDrawer(),
      ),
    );
  }

  Widget _leftDrawer() {
    return const Drawer(
      elevation: 3,
      child: SideMainMenu(),
    );
  }

  void _retryConnectionToAuthorize(WidgetRef ref) {
    requestStartUpSignIn = true;
    return ref.refresh(signInProvider);
  }
}

class MainPanel extends StatelessWidget {
  final List<Widget> widgetList;

  const MainPanel({super.key, required this.widgetList});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }
}
