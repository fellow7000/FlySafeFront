import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/delete_club_request.dart';
import '../../Core/DTO/Club/delete_club_response.dart';
import '../../Core/DTO/Club/leave_club_request.dart';
import '../../Core/DTO/Club/leave_club_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';

//Confirmation dialog for leaving a club. Pops true after a successful call.
class LeaveClubDialog extends ConsumerStatefulWidget {
  const LeaveClubDialog({required this.clubId, required this.clubName, super.key});

  final String clubId;
  final String clubName;

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
    final lastOwner = ClubErrorHelper.hasCode(_errors, ClubErrorCodes.lastOwnerCannotLeave);

    return AlertDialog(
      title: Text("LeaveClub".tr()),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("LeaveClubConfirmation".tr(args: [widget.clubName])),
          if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: ref.watch(deltaFontSizeProvider)),
          if (lastOwner) Padding(padding: const EdgeInsets.only(top: 10), child: Text("LastOwnerCannotLeaveHint".tr())),
        ]),
      ),
      actions: [
        TextButton(onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false), child: Text("Cancel".tr())),
        _isProcessing
            ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
            : TextButton(onPressed: lastOwner ? null : _leave, child: Text("LeaveClub".tr())),
      ],
    );
  }
}

//Confirmation dialog for deleting a club: club name and own user password are required. Pops true after a successful call.
class DeleteClubDialog extends ConsumerStatefulWidget {
  const DeleteClubDialog({required this.clubId, required this.clubName, super.key});

  final String clubId;
  final String clubName;

  @override
  ConsumerState<DeleteClubDialog> createState() => _DeleteClubDialogState();
}

class _DeleteClubDialogState extends ConsumerState<DeleteClubDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isProcessing = false;
  bool _isPasswordHidden = true;
  List<CallError> _errors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isInputComplete => _nameController.text == widget.clubName && _passwordController.text.isNotEmpty;

  Future<void> _delete() async {
    setState(() {
      _isProcessing = true;
      _errors = [];
    });

    ref.read(deleteClubRequestProvider.notifier).state =
        DeleteClubRequest(clubId: widget.clubId, clubNameConfirmation: _nameController.text, userPassword: _passwordController.text);

    try {
      final DeleteClubResponse response = await ref.read(deleteClubProvider.future);
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
    return AlertDialog(
      title: Text("DeleteClub".tr()),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("DeleteClubWarning".tr(args: [widget.clubName])),
          TextField(
            controller: _nameController,
            enabled: !_isProcessing,
            decoration: InputDecoration(labelText: "DeleteClubTypeName".tr()),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _passwordController,
            enabled: !_isProcessing,
            obscureText: _isPasswordHidden,
            decoration: InputDecoration(
              labelText: "DeleteClubYourPassword".tr(),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: ref.watch(deltaFontSizeProvider)),
        ]),
      ),
      actions: [
        TextButton(onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false), child: Text("Cancel".tr())),
        _isProcessing
            ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
            : TextButton(
                onPressed: _isInputComplete ? _delete : null,
                child: Text("DeleteClub".tr(), style: TextStyle(color: _isInputComplete ? Theme.of(context).colorScheme.error : null))),
      ],
    );
  }
}
