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
import 'club_action_dialogs.dart';
import 'club_ui.dart';
import 'delete_club.dart';

class ClubDetails extends ConsumerWidget {
  const ClubDetails({required this.clubId, super.key});

  final String clubId;
  static const double _divIndent = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ClubStyles.of(context, ref.watch(deltaFontSizeProvider));

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(), form: AppProcessIndicator(message: "Loading".tr()));
    }

    //clubDetailsRequestProvider is updated in the form Club_list_and_actions
    final clubDetailsWidget = ref.watch(clubDetailProvider).when(
        loading: () => AppProcessIndicator(message: "Loading".tr()),
        data: (data) {
          final club = data.club;

          //if the user may not get the club details, show a message and stop
          if (club == null || !IdentityHelper.isActionAllowed(appAction: AppAction.readClubBaseInfo, allowedActions: data.allowedActions)) {
            return ClubCard(children: [Padding(padding: const EdgeInsets.all(10), child: Text("NoAccessToClub".tr(), style: styles.body))]);
          }

          bool allowed(AppAction action) => IdentityHelper.isActionAllowed(appAction: action, allowedActions: data.allowedActions);
          const divider = Divider(indent: _divIndent, endIndent: _divIndent);
          final canEditType = allowed(AppAction.editClubBaseInfo);
          final canLeave = allowed(AppAction.leaveClub);
          final canDelete = allowed(AppAction.deleteClub);

          final fields = <Widget>[
            //Card title: the club itself; the name is not repeated as a row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(club.clubName, textAlign: TextAlign.center, style: styles.cardTitle),
            ),

            //Club type: editable for the Owner (EditClubBaseInfo), otherwise an info row
            ListTile(
              key: const Key("clubTypeRow"),
              leading: Icon(club.clubType == ClubType.publicClub ? visibleIcon : notVisibleIcon, size: styles.iconSize),
              title: Text("ClubType".tr(), style: styles.label),
              subtitle: Text(clubTypeLabel(club.clubType), style: styles.value),
              trailing: canEditType ? Icon(chevronExpand, size: styles.iconSize) : null,
              onTap: canEditType ? () => _changeClubType(context, ref, club.clubType) : null,
            ),
          ];

          //Own roles, one per line; shown only if the club list is already loaded
          final roles = ref.watch(getClubsRolesActionsProvider).value?.clubAndRoleDTOList.where((c) => c.clubID == club.clubID).expand((c) => c.roles).map((r) => r.item2).toList();
          if (roles != null && roles.isNotEmpty) {
            fields.add(divider);
            fields.add(ListTile(
              key: const Key("clubRolesRow"),
              leading: Icon(userIcon, size: styles.iconSize),
              title: Text(roles.length > 1 ? "Roles".tr() : "Role".tr(), style: styles.label),
              subtitle: ClubRolesText(roleNames: roles, style: styles.value),
            ));
          }

          //Change Club Password; member management (AppAction.getClubMembers) is not shown until it is implemented
          if (allowed(AppAction.changeClubPassword)) {
            fields.add(divider);
            fields.add(ListTile(
              leading: Icon(passwordIcon, size: styles.iconSize),
              title: Text("ChangeClubPassword".tr(), style: styles.value),
              trailing: Icon(chevronExpand, size: styles.iconSize),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeClubPassword(clubId: clubId, clubName: club.clubName))),
            ));
          }

          //Destructive actions at the bottom, set apart by space; only the leading icon is red
          if (canLeave || canDelete) {
            fields.add(const SizedBox(height: 20));
            fields.add(divider);
          }

          if (canLeave) {
            fields.add(ListTile(
              leading: Icon(logOutIcon, size: styles.iconSize, color: styles.danger),
              title: Text("LeaveClub".tr(), style: styles.value),
              trailing: Icon(chevronExpand, size: styles.iconSize),
              onTap: () => _leaveClub(context, ref, club.clubName, canDelete),
            ));
            if (canDelete) fields.add(divider);
          }

          if (canDelete) {
            fields.add(ListTile(
              leading: Icon(clearTextIcon, size: styles.iconSize, color: styles.danger),
              title: Text("DeleteClub".tr(), style: styles.value),
              trailing: Icon(chevronExpand, size: styles.iconSize),
              onTap: () => _deleteClub(context, ref, club.clubName),
            ));
          }

          return ClubCard(children: fields);
        },
        error: (err, stack) => ApiErrorTileRetry(
              err: err,
              errorMessage: "BackEndComError".tr(),
              errorStack: stack,
              tapToRetryHint: clickToRetry.tr(),
              deltaSize: ref.watch(deltaFontSizeProvider),
              retryCallBack: () => reloadClubDetails(ref),
            ));

    return BasisForm(formTitle: "Clubs".tr(), form: clubDetailsWidget);
  }

  Future<void> _changeClubType(BuildContext context, WidgetRef ref, ClubType currentType) async {
    final changed = await showDialog<bool>(
        context: context, barrierDismissible: false, builder: (_) => ChangeClubTypeDialog(clubId: clubId, currentType: currentType));
    if (changed != true || !context.mounted) return;
    AppHelper.showSnack(context: context, message: "ClubTypeChanged".tr());
    ref.invalidate(clubDetailProvider);
    ref.invalidate(getClubsRolesActionsProvider);
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
