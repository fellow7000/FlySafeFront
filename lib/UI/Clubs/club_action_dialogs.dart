import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/change_club_type_request.dart';
import '../../Core/DTO/Club/change_club_type_response.dart';
import '../../Core/DTO/Club/leave_club_request.dart';
import '../../Core/DTO/Club/leave_club_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import 'club_ui.dart';

enum LeaveClubResult { cancelled, left, deleteInstead }

//Confirmation dialog for leaving a club. Pops a LeaveClubResult; left means the call succeeded.
//The server does not offer Leave to the only Owner; LastOwnerCannotLeave is handled as a rare fallback.
class LeaveClubDialog extends ConsumerStatefulWidget {
  const LeaveClubDialog({required this.clubId, required this.clubName, this.canDelete = false, super.key});

  final String clubId;
  final String clubName;
  final bool canDelete;

  @override
  ConsumerState<LeaveClubDialog> createState() => _LeaveClubDialogState();
}

class _LeaveClubDialogState extends ConsumerState<LeaveClubDialog> {
  bool _isProcessing = false;
  List<CallError> _errors = [];

  Future<void> _leave() async {
    setState(() {
      _isProcessing = true;
      _errors = [];
    });

    ref.read(leaveClubRequestProvider.notifier).state = LeaveClubRequest(clubId: widget.clubId);

    try {
      final response = await ref.read(leaveClubProvider.future);
      if (!mounted) return;
      if (response.resultCode == AppResultCode.ok) {
        Navigator.of(context).pop(LeaveClubResult.left);
      } else {
        setState(() {
          _errors = ClubErrorHelper.localize(response.errors);
          _isProcessing = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errors = [BackEndCall.callExceptionError];
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastOwner = ClubErrorHelper.hasCode(_errors, ClubErrorCodes.lastOwnerCannotLeave);
    final delta = ref.watch(deltaFontSizeProvider);
    final styles = ClubStyles.of(context, delta);

    return AlertDialog(
      icon: Icon(logOutIcon, size: styles.iconSize + 8, color: styles.danger),
      title: Text("LeaveClub".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("LeaveClubConfirmation".tr(args: [widget.clubName]), style: styles.body),
          if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: delta),
          if (lastOwner && widget.canDelete) Padding(padding: const EdgeInsets.only(top: 10), child: Text("LastOwnerCannotLeaveHint".tr(), style: styles.body)),
        ]),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(LeaveClubResult.cancelled),
            child: Text(lastOwner ? "Close".tr() : "Cancel".tr(), style: styles.label)),
        if (_isProcessing)
          clubDialogProgress
        else if (lastOwner && widget.canDelete)
          ElevatedButton(
            style: styles.destructiveButton,
            onPressed: () => Navigator.of(context).pop(LeaveClubResult.deleteInstead),
            child: Text("DeleteClub".tr(), style: styles.label.copyWith(color: Colors.white)),
          )
        else if (!lastOwner)
          ElevatedButton(
            style: styles.destructiveButton,
            onPressed: _leave,
            child: Text("LeaveClub".tr(), style: styles.label.copyWith(color: Colors.white)),
          ),
      ],
    );
  }
}

//Dialog to switch a club between listed (public) and not listed. Pops true after a successful change.
class ChangeClubTypeDialog extends ConsumerStatefulWidget {
  const ChangeClubTypeDialog({required this.clubId, required this.currentType, super.key});

  static const List<ClubType> selectableTypes = [ClubType.publicClub, ClubType.nonListedClub];

  final String clubId;
  final ClubType currentType;

  @override
  ConsumerState<ChangeClubTypeDialog> createState() => _ChangeClubTypeDialogState();
}

class _ChangeClubTypeDialogState extends ConsumerState<ChangeClubTypeDialog> {
  late ClubType _selected = widget.currentType;
  bool _isProcessing = false;
  List<CallError> _errors = [];

  Future<void> _save() async {
    setState(() {
      _isProcessing = true;
      _errors = [];
    });

    ref.read(changeClubTypeRequestProvider.notifier).state = ChangeClubTypeRequest(clubId: widget.clubId, newClubType: _selected);

    try {
      final response = await ref.read(changeClubTypeProvider.future);
      if (!mounted) return;
      if (response.resultCode == AppResultCode.ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errors = ClubErrorHelper.localize(response.errors);
          _isProcessing = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errors = [BackEndCall.callExceptionError];
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final delta = ref.watch(deltaFontSizeProvider);
    final styles = ClubStyles.of(context, delta);

    return AlertDialog(
      title: Text("ChangeClubType".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioGroup<ClubType>(
            groupValue: _selected,
            onChanged: (value) {
              if (!_isProcessing && value != null) setState(() => _selected = value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ChangeClubTypeDialog.selectableTypes
                  .map((type) => RadioListTile<ClubType>(
                        value: type,
                        enabled: !_isProcessing,
                        contentPadding: EdgeInsets.zero,
                        title: Text(clubTypeLabel(type), style: styles.value),
                        subtitle: Text(type == ClubType.publicClub ? "ClubTypePublicHint".tr() : "ClubTypePrivateHint".tr(), style: styles.label),
                      ))
                  .toList(),
            ),
          ),
          if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: delta),
        ]),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false), child: Text("Cancel".tr(), style: styles.label)),
        if (_isProcessing)
          clubDialogProgress
        else
          ElevatedButton(
            style: styles.primaryButton,
            onPressed: _selected == widget.currentType ? null : _save,
            child: Text("Save".tr(), style: styles.label.copyWith(color: Colors.white)),
          ),
      ],
    );
  }
}

String clubTypeLabel(ClubType type) => type == ClubType.publicClub ? "ClubTypePublic".tr() : "ClubTypePrivate".tr();
