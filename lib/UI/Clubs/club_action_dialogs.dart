import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/leave_club_request.dart';
import '../../Core/DTO/Club/leave_club_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Themes/app_themes.dart';

enum LeaveClubResult { cancelled, left, deleteInstead }

//Confirmation dialog for leaving a club. Pops a LeaveClubResult; left means the call succeeded.
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final warningColor = isLight ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark;
    final iconSize = appIconBasisSize + delta;

    return AlertDialog(
      icon: Icon(logOutIcon, size: iconSize + 8, color: warningColor),
      title: Text("LeaveClub".tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: delta)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("LeaveClubConfirmation".tr(args: [widget.clubName]), style: textStyleTitleMedium.copyWith(color: warningColor)),
          if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: delta),
          if (lastOwner) Padding(padding: const EdgeInsets.only(top: 10), child: Text("LastOwnerCannotLeaveHint".tr(), style: textStyleTitleMedium.copyWith(fontWeight: FontWeight.bold))),
        ]),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(LeaveClubResult.cancelled),
            child: Text("Cancel".tr(), style: textStyleTitleMedium)),
        if (_isProcessing)
          const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
        else if (lastOwner && widget.canDelete)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: warningColor),
            onPressed: () => Navigator.of(context).pop(LeaveClubResult.deleteInstead),
            child: Text("DeleteClub".tr(), style: textStyleTitleMedium.copyWith(color: Colors.white)),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: warningColor, disabledBackgroundColor: isLight ? primaryWarningButtonDisabledColorLight : primaryWarningButtonDisabledColorDark),
            onPressed: lastOwner ? null : _leave,
            child: Text("LeaveClub".tr(), style: textStyleTitleMedium.copyWith(color: Colors.white)),
          ),
      ],
    );
  }
}
