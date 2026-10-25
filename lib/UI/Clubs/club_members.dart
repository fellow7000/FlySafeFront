import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Club/club_member_dto.dart';
import '../../Core/DTO/Club/get_club_members_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Helpers/club_error_helper.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';
import 'add_club_member.dart';
import 'club_member_dialogs.dart';
import 'club_ui.dart';

const _divider = Divider(indent: 10, endIndent: 10);

//Loads the member list and renders [builder] with it; loading, call errors and refusals (403/404) are handled here.
Widget _membersView(BuildContext context, WidgetRef ref, String clubId, Widget Function(GetClubMembersResponse data, ClubStyles styles) builder) {
  final delta = ref.watch(deltaFontSizeProvider);
  final styles = ClubStyles.of(context, delta);
  return ref.watch(getClubMembersProvider(clubId)).when(
        loading: () => AppProcessIndicator(message: "Loading".tr()),
        error: (err, stack) => ApiErrorTileRetry(
          err: err,
          errorMessage: "BackEndComError".tr(),
          errorStack: stack,
          tapToRetryHint: clickToRetry.tr(),
          deltaSize: delta,
          retryCallBack: () => ref.invalidate(getClubMembersProvider(clubId)),
        ),
        data: (data) => data.resultCode == AppResultCode.ok
            ? builder(data, styles)
            : ClubCard(children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(ClubErrorHelper.message(ClubErrorHelper.localize(data.errors)), textAlign: TextAlign.center, style: styles.body)),
              ]),
      );
}

///Members of a club. Shown only to users with GetClubMembers (Owners, Managers, Root). Names and roles only, no emails.
class ClubMembers extends ConsumerWidget {
  const ClubMembers({required this.clubId, required this.clubName, super.key});

  final String clubId;
  final String clubName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = _membersView(context, ref, clubId, (data, styles) {
      final fields = <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text("Members".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
        ),
      ];

      for (final member in data.members) {
        if (member != data.members.first) fields.add(_divider);
        fields.add(ListTile(
          key: Key("member_${member.userId}"),
          leading: Icon(userIcon, size: styles.iconSize),
          title: Text.rich(TextSpan(text: member.userName, children: [
            if (member.isCurrentUser) TextSpan(text: "  (${"You".tr()})", style: styles.label),
          ]), style: styles.value),
          subtitle: Text(member.role.tr(), style: styles.label),
          trailing: member.isManageable ? Icon(chevronExpand, size: styles.iconSize) : null,
          onTap: member.isManageable
              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClubMemberPage(clubId: clubId, clubName: clubName, userId: member.userId)))
              : null,
        ));
      }

      if (data.canAddMember) {
        fields.add(_divider);
        fields.add(ListTile(
          key: const Key("addMemberRow"),
          leading: Icon(addMemberIcon, size: styles.iconSize),
          title: Text("AddMember".tr(), style: styles.value),
          trailing: Icon(chevronExpand, size: styles.iconSize),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddClubMember(clubId: clubId, clubName: clubName))),
        ));
      }

      return ClubCard(children: fields);
    });

    return BasisForm(formTitle: clubName, form: view);
  }
}

///One member: the role (editable if the server offers other roles) and Remove from club at the bottom.
class ClubMemberPage extends ConsumerWidget {
  const ClubMemberPage({required this.clubId, required this.clubName, required this.userId, super.key});

  final String clubId;
  final String clubName;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = _membersView(context, ref, clubId, (data, styles) {
      final member = data.members.where((m) => m.userId == userId).firstOrNull;
      if (member == null) {
        return ClubCard(children: [
          Padding(padding: const EdgeInsets.all(10), child: Text("UserNotMember".tr(), textAlign: TextAlign.center, style: styles.body)),
        ]);
      }

      final canChangeRole = member.allowedRoles.isNotEmpty;
      final fields = <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(member.userName, textAlign: TextAlign.center, style: styles.cardTitle),
        ),
        ListTile(
          key: const Key("memberRoleRow"),
          leading: Icon(roleIcon, size: styles.iconSize),
          title: Text("Role".tr(), style: styles.label),
          subtitle: Text(member.role.tr(), style: styles.value),
          trailing: canChangeRole ? Icon(chevronExpand, size: styles.iconSize) : null,
          onTap: canChangeRole ? () => _changeRole(context, ref, member) : null,
        ),
      ];

      //Destructive action last, set apart by space; only the leading icon is red
      if (member.canRemove) {
        fields.add(const SizedBox(height: 20));
        fields.add(_divider);
        fields.add(ListTile(
          key: const Key("removeMemberRow"),
          leading: Icon(removeMemberIcon, size: styles.iconSize, color: styles.danger),
          title: Text("RemoveFromClub".tr(), style: styles.value),
          trailing: Icon(chevronExpand, size: styles.iconSize),
          onTap: () => _remove(context, ref, member),
        ));
      }

      return ClubCard(children: fields);
    });

    return BasisForm(formTitle: clubName, form: view);
  }

  Future<void> _changeRole(BuildContext context, WidgetRef ref, ClubMemberDTO member) async {
    final changed =
        await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => ChangeMemberRoleDialog(clubId: clubId, member: member));
    if (changed != true || !context.mounted) return;
    AppHelper.showSnack(context: context, message: "MemberRoleChanged".tr());
    ref.invalidate(getClubMembersProvider(clubId));
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, ClubMemberDTO member) async {
    final removed = await showDialog<bool>(
        context: context, barrierDismissible: false, builder: (_) => RemoveMemberDialog(clubId: clubId, clubName: clubName, member: member));
    if (removed != true || !context.mounted) return;
    AppHelper.showSnack(context: context, message: "MemberRemoved".tr());
    ref.invalidate(getClubMembersProvider(clubId));
    Navigator.of(context).pop();
  }
}
