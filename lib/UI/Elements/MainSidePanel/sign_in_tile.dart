import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/UI/Identity/Manage/account_manager.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Vars/enums.dart';
import '../../Themes/app_themes.dart';

class SignInTile extends ConsumerWidget {

  final String signInLabel;
  final String userOrClubName;

  const SignInTile({
    super.key,
    required this.signInLabel,
    required this.userOrClubName,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    final TextStyle textStyle = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta);
    final Color iconColor = Theme.of(context).brightness == Brightness.light ? appBarIconColorLight : appBarIconColorDark;

    if (winWidth != WindowWidth.large) { //TODO: 27.12.2022 quick hack
      if (ref.watch(authStateProvider) == LogAs.none) {
        return IconButton(onPressed: () => _toSignInForm(context: context, ref: ref, logAs: LogAs.userOrClub, popWindow: false), icon: Icon(loginIcon, color: iconColor, size: iconSize));
      } else if (ref.watch(authStateProvider) == LogAs.user) {
        return IconButton(onPressed: () => _toAccountManager(context: context, popWindow: false), icon: Icon(userIcon, color: iconColor, size: iconSize));
      } else if (ref.watch(authStateProvider) == LogAs.club) {
        return IconButton(onPressed: () => _toAccountManager(context: context, popWindow: false), icon: Icon(clubIcon, color: iconColor, size: iconSize));
      } else {
        return Container();
      }
    } else {
      if (ref.watch(authStateProvider) == LogAs.none) {
        return ListTile(
          leading: Icon(loginIcon, size: iconSize),
          title: Text(signInLabel, style: textStyle),
          onTap: () => _toSignInForm(context: context, ref: ref, logAs: LogAs.userOrClub, popWindow: false),
        );
      } else if (ref.watch(authStateProvider) == LogAs.user) {
        return ListTile(
          leading: Icon(userIcon, size: iconSize),
          title: Text(userOrClubName, style: textStyle),
          onTap: () => _toAccountManager(context: context, popWindow: false),
        );
      } else if (ref.watch(authStateProvider) == LogAs.club) {
        return ListTile(
          leading: Icon(clubIcon, size: iconSize),
          title: Text(userOrClubName, style: textStyle),
          onTap: () => _toAccountManager(context: context, popWindow: false),
        );
      } else {
        return Container();
      }
    }
  }

  _toSignInForm({required BuildContext context, required WidgetRef ref, required LogAs logAs, required bool popWindow}) {
    if (popWindow) {
      Navigator.pop(context, false);
    }

    ref.read(toSignAsProvider.notifier).state = logAs;
    context.go('/login');

  }

  _toAccountManager({required BuildContext context, required bool popWindow}) {
    if (popWindow) {
      Navigator.pop(context, false);
    }
    loadUserOrClubProfile = true;
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => const AccountManager()
    ));
  }
}