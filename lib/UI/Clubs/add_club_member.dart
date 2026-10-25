import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/add_club_member_request.dart';
import '../../Core/DTO/Club/get_club_members_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';
import 'club_ui.dart';

///Adds an existing user by exact user name or email. The server answers the same whether the user exists or not,
///so the success message is neutral; the refreshed member list shows the result.
class AddClubMember extends ConsumerStatefulWidget {
  const AddClubMember({required this.clubId, required this.clubName, super.key});

  final String clubId;
  final String clubName;

  @override
  ConsumerState<AddClubMember> createState() => _AddClubMemberState();
}

class _AddClubMemberState extends ConsumerState<AddClubMember> {
  final _controller = TextEditingController();
  bool _isProcessing = false;
  List<CallError> _errors = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_isProcessing && _controller.text.trim().isNotEmpty;

  Future<void> _add() async {
    if (!_canSubmit) return;
    setState(() {
      _isProcessing = true;
      _errors = [];
    });
    try {
      final response = await ref
          .read(backEndClub)
          .addClubMember(addClubMemberRequest: AddClubMemberRequest(clubId: widget.clubId, userNameOrEmail: _controller.text.trim()));
      if (!mounted) return;
      if (response.resultCode == AppResultCode.ok) {
        AppHelper.showSnack(context: context, message: "MemberAddedNeutral".tr(), msec: 4000);
        ref.invalidate(getClubMembersProvider(widget.clubId));
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

    final fields = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("AddMember".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text("AddMemberHint".tr(), textAlign: TextAlign.center, style: styles.body),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
          key: const Key("addMemberField"),
          controller: _controller,
          enabled: !_isProcessing,
          style: styles.value,
          maxLength: AddClubMemberRequest.maxLength,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: "UserNameOrEmail".tr(),
            prefixIcon: Icon(userIcon, size: styles.iconSize),
            border: const OutlineInputBorder(),
            counterText: "",
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _add(),
        ),
      ),
      if (_errors.isNotEmpty) ApiErrorMessages(callErrors: _errors, deltaFontSize: delta),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: _isProcessing
            ? AppProcessIndicator(message: "Processing".tr())
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key("addMemberButton"),
                  style: styles.primaryButton,
                  onPressed: _canSubmit ? _add : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(fit: BoxFit.scaleDown, child: Text("AddMember".tr(), textAlign: TextAlign.center, style: styles.buttonLabel))),
                ),
              ),
      ),
    ];

    return BasisForm(formTitle: widget.clubName, form: ClubCard(children: fields));
  }
}
