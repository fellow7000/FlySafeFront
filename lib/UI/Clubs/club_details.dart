import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Helpers/identity_helper.dart';

import '../../Core/DTO/Club/club_details_response.dart';
import '../../Core/DTO/Identity/Manage/get_clubs_roles_actions.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';
import '../../Helpers/app_helper.dart';
import 'change_club_password.dart';
import '../Themes/app_themes.dart';
import 'club_action_dialogs.dart';
import 'delete_club.dart';

class ClubDetails extends ConsumerWidget {
  const ClubDetails({required this.clubId, super.key});

  final String clubId;
  final double _myElevation = 3;
  static const double _divIndent = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    List<Widget> fields = <Widget>[];

    Widget clubDetailsWidget;

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(), form: AppProcessIndicator(message: "Loading".tr()));
    }

    //clubDetailsRequestProvider is updated in the form Club_list_and_actions

    clubDetailsWidget = ref.watch(clubDetailProvider).when(
        loading: () => AppProcessIndicator(message: "Loading".tr()),
        data: (data) {
          final club = data.club;

          //if the user may not get the club details, show a message and stop
          if (club == null || !IdentityHelper.isActionAllowed(appAction: AppAction.readClubBaseInfo, allowedActions: data.allowedActions)) {
            fields.add(Text("NoAccessToClub".tr()));
          } else {
            final iconSize = appIconBasisSize + fontSizeDelta;
            final isLight = Theme.of(context).brightness == Brightness.light;
            final warningColor = isLight ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark;
            const divider = Divider(indent: _divIndent, endIndent: _divIndent);

            fields.add(Padding(
              padding: const EdgeInsets.all(10),
              child: Text(club.clubName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)),
            ));

            //Club name
            fields.add(ListTile(
              leading: Icon(clubIcon, size: iconSize, color: isLight ? validColorLight : validColorDark),
              title: Text("ClubName".tr(), style: textStyleTitleMedium),
              subtitle: Text(club.clubName, style: textStyleTitleLarge),
            ));
            fields.add(divider);

            //Club type
            fields.add(ListTile(
              leading: Icon(club.clubType == ClubType.publicClub ? visibleIcon : notVisibleIcon, size: iconSize),
              title: Text("ClubType".tr(), style: textStyleTitleMedium),
              subtitle: Text(club.clubType == ClubType.publicClub ? "ClubTypePublic".tr() : "ClubTypePrivate".tr(), style: textStyleTitleLarge),
            ));
            fields.add(divider);

            //Own roles; shown only if the club list is already loaded
            final roles = ref.watch(getClubsRolesActionsProvider).value?.clubAndRoleDTOList.where((c) => c.clubID == club.clubID).expand((c) => c.roles).toList();
            if (roles != null && roles.isNotEmpty) {
              fields.add(ListTile(
                leading: Icon(userIcon, size: iconSize),
                title: Text("Role".tr(), style: textStyleTitleMedium),
                subtitle: Text(roles.map((r) => r.item2.tr()).join(", "), style: textStyleTitleLarge),
              ));
              fields.add(divider);
            }

            //Change Club Password; member management (AppAction.getClubMembers) is not shown until it is implemented
            if (IdentityHelper.isActionAllowed(appAction: AppAction.changeClubPassword, allowedActions: data.allowedActions)) {
              fields.add(ListTile(
                leading: Icon(passwordIcon, size: iconSize),
                title: Text("ChangeClubPassword".tr(), style: textStyleTitleLarge),
                trailing: Icon(chevronExpand, size: iconSize),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeClubPassword(clubId: clubId))),
              ));
              fields.add(divider);
            }

            final canLeave = IdentityHelper.isActionAllowed(appAction: AppAction.leaveClub, allowedActions: data.allowedActions);
            final canDelete = IdentityHelper.isActionAllowed(appAction: AppAction.deleteClub, allowedActions: data.allowedActions);

            //Danger section
            if (canLeave || canDelete) {
              fields.add(Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: Text("DangerZone".tr(), style: textStyleTitleMedium.copyWith(color: warningColor, fontWeight: FontWeight.bold)),
              ));
              fields.add(Divider(indent: _divIndent, endIndent: _divIndent, color: warningColor));
            }

            if (canLeave) {
              fields.add(ListTile(
                leading: Icon(logOutIcon, size: iconSize, color: warningColor),
                title: Text("LeaveClub".tr(), style: textStyleTitleLarge.copyWith(color: warningColor)),
                trailing: Icon(chevronExpand, size: iconSize),
                onTap: () => _leaveClub(context, ref, club.clubName, canDelete),
              ));
              if (canDelete) fields.add(divider);
            }

            if (canDelete) {
              fields.add(ListTile(
                leading: Icon(clearTextIcon, size: iconSize, color: warningColor),
                title: Text("DeleteClub".tr(), style: textStyleTitleLarge.copyWith(color: warningColor)),
                trailing: Icon(chevronExpand, size: iconSize),
                onTap: () => _deleteClub(context, ref, club.clubName),
              ));
            }
          }

          return Column(
            children: [
              Card(
                elevation: _myElevation,
                child: Padding(
                  padding: const EdgeInsets.all(formPadding),
                  child: Column(children: fields), //Sign-in Form
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: formPadding)),
            ],
          );
        },
        error: (err, stack) => ApiErrorTileRetry(
              err: err,
              errorMessage: "BackEndComError".tr(),
              errorStack: stack,
              tapToRetryHint: clickToRetry.tr(),
              deltaSize: ref.watch(deltaFontSizeProvider),
              retryCallBack: () => reloadClubDetails(ref),
            ));

    return BasisForm(formTitle: "Club".tr(), form: clubDetailsWidget);
  }

  Future<void> _leaveClub(BuildContext context, WidgetRef ref, String clubName, bool canDelete) async {
    final result = await showDialog<LeaveClubResult>(
        context: context, barrierDismissible: false, builder: (_) => LeaveClubDialog(clubId: clubId, clubName: clubName, canDelete: canDelete));
    if (!context.mounted || result == null || result == LeaveClubResult.cancelled) return;
    if (result == LeaveClubResult.deleteInstead) {
      await _deleteClub(context, ref, clubName);
      return;
    }
    _finish(context, ref, "ClubLeft".tr());
  }

  Future<void> _deleteClub(BuildContext context, WidgetRef ref, String clubName) async {
    final done = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => DeleteClub(clubId: clubId, clubName: clubName)));
    if (done != true || !context.mounted) return;
    _finish(context, ref, "ClubDeleted".tr());
  }

  //after a successful leave/delete the user has no access to the club anymore: refresh the lists and go back to the club list
  void _finish(BuildContext context, WidgetRef ref, String message) {
    AppHelper.showSnack(context: context, message: message);
    ref.invalidate(getUserProfileProvider);
    ref.invalidate(getClubsRolesActionsProvider);
    Navigator.of(context).pop();
  }

  void reloadClubDetails(WidgetRef ref) {
    return ref.refresh(clubDetailProvider);
  }
}
