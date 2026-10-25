import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/club_member_change_response.dart';
import '../../Core/DTO/Club/club_member_dto.dart';
import '../../Core/DTO/Club/remove_club_member_request.dart';
import '../../Core/DTO/Club/set_club_member_role_request.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import 'club_ui.dart';

//Runs a member call and keeps the dialog state (processing, errors). Pops true after success.
mixin _MemberCallState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool isProcessing = false;
  List<CallError> errors = [];

  Future<void> runMemberCall(Future<ClubMemberChangeResponse> Function() call) async {
    setState(() {
      isProcessing = true;
      errors = [];
    });
    try {
      final response = await call();
      if (!mounted) return;
      if (response.resultCode == AppResultCode.ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          errors = ClubErrorHelper.localize(response.errors);
          isProcessing = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errors = [BackEndCall.callExceptionError];
        isProcessing = false;
      });
    }
  }
}

//Radio dialog to change a member's role, like the club type dialog. Only the roles the server allows are offered.
class ChangeMemberRoleDialog extends ConsumerStatefulWidget {
  const ChangeMemberRoleDialog({required this.clubId, required this.member, super.key});

  static const List<String> roleOrder = [ClubMemberDTO.owner, ClubMemberDTO.manager, ClubMemberDTO.member];

  final String clubId;
  final ClubMemberDTO member;

  static String roleHint(String role) => switch (role) {
        ClubMemberDTO.owner => "ClubOwnerHint".tr(),
        ClubMemberDTO.manager => "ClubManagerHint".tr(),
        _ => "ClubMemberHint".tr(),
      };

  @override
  ConsumerState<ChangeMemberRoleDialog> createState() => _ChangeMemberRoleDialogState();
}

class _ChangeMemberRoleDialogState extends ConsumerState<ChangeMemberRoleDialog> with _MemberCallState {
  late String _selected = widget.member.role;

  List<String> get _roles {
    final offered = {widget.member.role, ...widget.member.allowedRoles};
    return [...ChangeMemberRoleDialog.roleOrder.where(offered.contains), ...offered.where((r) => !ChangeMemberRoleDialog.roleOrder.contains(r))];
  }

  @override
  Widget build(BuildContext context) {
    final delta = ref.watch(deltaFontSizeProvider);
    final styles = ClubStyles.of(context, delta);

    return AlertDialog(
      title: Text("ChangeRole".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.member.userName, textAlign: TextAlign.center, style: styles.body),
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (value) {
              if (!isProcessing && value != null) setState(() => _selected = value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _roles
                  .map((role) => RadioListTile<String>(
                        key: Key("roleOption_$role"),
                        value: role,
                        enabled: !isProcessing,
                        contentPadding: EdgeInsets.zero,
                        title: Text(role.tr(), style: styles.value),
                        subtitle: Text(ChangeMemberRoleDialog.roleHint(role), style: styles.label),
                      ))
                  .toList(),
            ),
          ),
          if (errors.isNotEmpty) ApiErrorMessages(callErrors: errors, deltaFontSize: delta),
        ]),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(onPressed: isProcessing ? null : () => Navigator.of(context).pop(false), child: Text("Cancel".tr(), style: styles.label)),
        if (isProcessing)
          clubDialogProgress
        else
          ElevatedButton(
            key: const Key("saveRoleButton"),
            style: styles.primaryButton,
            onPressed: _selected == widget.member.role
                ? null
                : () => runMemberCall(() => ref
                    .read(backEndClub)
                    .setClubMemberRole(setClubMemberRoleRequest: SetClubMemberRoleRequest(clubId: widget.clubId, userId: widget.member.userId, role: _selected))),
            child: Text("Save".tr(), style: styles.label.copyWith(color: Colors.white)),
          ),
      ],
    );
  }
}

//Confirmation for removing a member. Reversible (the member can be added again), so a dialog without typed confirmation.
//Red only for the icon, the title and the warning sentence.
class RemoveMemberDialog extends ConsumerStatefulWidget {
  const RemoveMemberDialog({required this.clubId, required this.clubName, required this.member, super.key});

  final String clubId;
  final String clubName;
  final ClubMemberDTO member;

  @override
  ConsumerState<RemoveMemberDialog> createState() => _RemoveMemberDialogState();
}

class _RemoveMemberDialogState extends ConsumerState<RemoveMemberDialog> with _MemberCallState {
  @override
  Widget build(BuildContext context) {
    final delta = ref.watch(deltaFontSizeProvider);
    final styles = ClubStyles.of(context, delta);

    return AlertDialog(
      icon: Icon(removeMemberIcon, size: styles.iconSize + 8, color: styles.danger),
      title: Text("RemoveMember".tr(),
          key: const Key("removeMemberTitle"), textAlign: TextAlign.center, style: styles.cardTitle.copyWith(color: styles.danger, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("RemoveMemberWarning".tr(args: [widget.member.userName, widget.clubName]),
              key: const Key("removeMemberWarning"), style: styles.body.copyWith(color: styles.danger, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text("RemoveMemberConsequences".tr(), key: const Key("removeMemberConsequences"), style: styles.body),
          ),
          if (errors.isNotEmpty) ApiErrorMessages(callErrors: errors, deltaFontSize: delta),
        ]),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(onPressed: isProcessing ? null : () => Navigator.of(context).pop(false), child: Text("Cancel".tr(), style: styles.label)),
        if (isProcessing)
          clubDialogProgress
        else
          ElevatedButton(
            key: const Key("removeMemberButton"),
            style: styles.destructiveButton,
            onPressed: () => runMemberCall(() => ref
                .read(backEndClub)
                .removeClubMember(removeClubMemberRequest: RemoveClubMemberRequest(clubId: widget.clubId, userId: widget.member.userId))),
            child: Text("Remove".tr(), style: styles.label.copyWith(color: Colors.white)),
          ),
      ],
    );
  }
}
