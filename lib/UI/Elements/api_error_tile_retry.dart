import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/exceptions.dart';
import 'package:fs_front/Helpers/identity_helper.dart';
import 'package:go_router/go_router.dart';

import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Themes/app_themes.dart';

class ApiErrorTileRetry extends ConsumerWidget {
  final Object err;
  final String errorMessage;
  final StackTrace? errorStack;
  final String tapToRetryHint;
  final Function? retryCallBack;
  final double deltaSize;

  const ApiErrorTileRetry({super.key, required this.err, required this.errorMessage, this.errorStack, required this.tapToRetryHint, this.retryCallBack, required this.deltaSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Function? callBack;
    if (retryCallBack!=null) callBack = retryCallBack!;
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    TextStyle? textStyle = Theme.of(context).textTheme.headlineSmall?.apply(fontSizeDelta: deltaSize);
    TextStyle? headLineSmallRed = Theme.of(context).textTheme.headlineSmall?.apply(fontSizeDelta: deltaSize, color: Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark);
    TextStyle? bodyMediumRed = Theme.of(context).textTheme.bodyMedium?.apply(fontSizeDelta: deltaSize, color: Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark);

    Widget body;

    if (err is Unauthorised) {
      debugPrint("Login failed 401");
      Future.delayed(Duration.zero, () => IdentityHelper.processSignOut(ref: ref));
      body = ListTile(
        leading: Icon(errorIcon, size: iconSize),
        title: Text("NotSignedIn".tr(), style: headLineSmallRed,),
        subtitle: Text("SignInAndRetry".tr(), style:  bodyMediumRed,),
        trailing: Icon(loginIcon, size: iconSize),
      );
      callBack = () => context.go('/login');
    } else if (err is Forbidden) {
      debugPrint("Access denied 403");
      body = ListTile(
        leading: Icon(errorIcon, size: iconSize),
        title: Text("AccessDenied".tr(), style: headLineSmallRed,),
        subtitle: Text("NotAuthorised".tr(), style:  bodyMediumRed,),
      );
    } else {
      debugPrint("Server Error");
      body = ListTile(
        title: FittedBox(fit: BoxFit.scaleDown, child: Text(errorMessage, style: headLineSmallRed)),
        subtitle: FittedBox(fit: BoxFit.scaleDown, child: Text(kDebugMode?errorStack.toString():tapToRetryHint),),
        trailing: Icon(retryIcon, size: iconSize,),
        //onTap: () => retryCallBack(),
      );
    }

    debugPrint(err.toString());
    if (errorStack!=null) debugPrintStack(stackTrace: errorStack);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: winWidth == WindowWidth.small?windowWidth - 50 : standardPanelWidth,
          child: ElevatedButton(
            style: ButtonStyle(elevation: WidgetStateProperty.all(3), backgroundColor: WidgetStateProperty.all(Colors.white)),
            onPressed: callBack!=null?() => callBack!():null,
            child: body,
          ),
        ),
      ),
    );
  }
}