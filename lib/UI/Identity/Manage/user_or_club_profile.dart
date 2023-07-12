import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:date_format/date_format.dart' as dtf;
import 'package:fs_front/Helpers/identity_helper.dart';
import 'package:fs_front/UI/Clubs/club_manager.dart';

import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../Themes/app_themes.dart';
import 'change_user_email.dart';
import 'change_user_password.dart';
import 'delete_user_account.dart';

class UserOrClubProfile extends ConsumerWidget {
  static const double myTopPadding = 0;
  static const double divIntent = 10;

  final UserProfileResponse userProfile;

  late final AutoDisposeProvider<TextEditingController> _userNameControllerProvider;
  late final AutoDisposeProvider<TextEditingController> _emailInputControllerProvider;
  late final AutoDisposeProvider<TextEditingController> _registrationDateControllerProvider;
  late final String registrationDateUTC;
  late final String registrationTimeUTC;

  UserOrClubProfile({required this.userProfile, super.key}) {
    _userNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
      final textController = TextEditingController(text: userProfile.userName);
      ref.onDispose(() {
        textController.dispose();
      });
      return textController;
    });

    _emailInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
      final textController = TextEditingController(text: userProfile.email);
      ref.onDispose(() {
        textController.dispose();
      });
      return textController;
    });

    String dateTimeUTC = userProfile.createdOn;
    String dateUTC = dateTimeUTC.substring(0, 10);
    registrationTimeUTC = dateTimeUTC.substring(11, 19);
    DateTime rawDateUTC = DateTime.parse(dateUTC);
    registrationDateUTC = dtf.formatDate(rawDateUTC, dateFormats[0]);

    _registrationDateControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
      String dateTimeUTC = userProfile.createdOn;
      String dateUTC = dateTimeUTC.substring(0, 10);
      String timeUTC = dateTimeUTC.substring(11, 19);
      DateTime rawDateUTC = DateTime.parse(dateUTC);
      final textController = TextEditingController(text: "${dtf.formatDate(rawDateUTC, dateFormats[0])}, $timeUTC");
      ref.onDispose(() {
        textController.dispose();
      });
      return textController;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    final logAs = ref.watch(authStateProvider);
    List<Widget> fields = <Widget>[];

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text(logAs == LogAs.user ? "UserProfile".tr() : "ClubProfile".tr(),
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)), //TODO: replace with code label
    ));

    //Username
    fields.add(Padding(
      padding: const EdgeInsets.only(top: myTopPadding),
      child: ListTile(
        leading: Icon(logAs == LogAs.user ? userIcon : clubIcon, size: iconSize, color: Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark),
        title: Text(logAs == LogAs.user ? "UserName".tr() : "ClubName".tr(), style: textStyleTitleMedium,),
        subtitle: Text(userProfile.userName, style: textStyleTitleLarge),
      ),
    ));

    fields.add(const Divider(
      indent: divIntent,
      endIndent: divIntent,
    ));

    if (logAs == LogAs.user) {
    //Email
    if (logAs == LogAs.user) {
      fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: ListTile(
          leading: Icon(emailIcon, size: iconSize, color: Theme
              .of(context)
              .brightness == Brightness.light ? validColorLight : validColorDark),
          trailing: logAs == LogAs.user?Icon(chevronExpand, size: iconSize):null,
          title: Text("Email".tr(), style: textStyleTitleMedium,),
          subtitle: Text(userProfile.email, style: textStyleTitleLarge),
          onTap: logAs == LogAs.user?() => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeUserEmail(userProfile: userProfile))):null,
        ),
      ));

      fields.add(const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ));
    }

    //Date of registration
    fields.add(Padding(
      padding: const EdgeInsets.only(top: myTopPadding),
      child: ListTile(
        leading: Icon(calenderIcon, size: iconSize),
        title: Text("RegistrationDate".tr(), style: textStyleTitleMedium,),
        subtitle: Text("$registrationDateUTC, $registrationTimeUTC", style: textStyleTitleLarge),
      ),
    ));

    fields.add(const Divider(
      indent: divIntent,
      endIndent: divIntent,
    ));

    //Club Management
    fields.add(Padding(
      padding: const EdgeInsets.only(top: myTopPadding),
      child: ListTile(
        leading: Icon(clubIcon, size: iconSize),
        title: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(fit: BoxFit.scaleDown, child: Text("ClubManagement".tr(), style: textStyleTitleLarge,))),
        trailing: Icon(chevronExpand, size: iconSize),
        onTap:() => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClubManager())),
      ),
    ));

    fields.add(const Divider(
      indent: divIntent,
      endIndent: divIntent,
    ));

    //Password & Security management
    fields.add(
      ListTile(
        leading: Icon(passwordIcon, size: iconSize),
        title: Text("Password".tr(), style: textStyleTitleLarge,),
        trailing: Icon(chevronExpand, size: iconSize),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeUserPassword())),
      )
    );

    fields.add(const Divider(
      indent: divIntent,
      endIndent: divIntent,
    ));

    //Delete Account
      fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: ListTile(
          leading: Icon(clearTextIcon, size: iconSize, color: Theme
              .of(context)
              .brightness == Brightness.light ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark),
          title: Text("DeleteUserAccount".tr(), style: textStyleTitleLarge,),
          trailing: Icon(chevronExpand, size: iconSize),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteUserAccount(userProfile: userProfile,))),
        ),
      ));

      fields.add(const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ));
    }

    //Logout button
    fields.add(
      SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.light ? primaryActionButtonDefEnabledColorLight : primaryActionButtonDefEnabledColorDark,
              ),
              onPressed: () => _logOut(context, ref),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      logOutIcon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text("SignOut".tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider), color: Colors.white)),
                    )
                  ],
                ),
              )
            )),
      ),
    );

    Widget profileForm = Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: fields), //Sign-in Form
    );

    return Column(
      children: [
        Card(
          elevation: 3,
          child: profileForm,
        ),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ],
    );
  }

  _logOut(BuildContext context, WidgetRef ref) {
    loadUserOrClubProfile = false;
    Navigator.pop(context);
    //Future.delayed(Duration(microseconds: 300), () => IdentityHelper.processSignOut(ref: ref));
    IdentityHelper.processSignOut(ref: ref);
  }
}
