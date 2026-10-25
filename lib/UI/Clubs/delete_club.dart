import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/delete_club_request.dart';
import '../../Core/DTO/Club/delete_club_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';
import 'club_ui.dart';

//Full-page confirmation for deleting a club: club name and own user password are required. Pops true after a successful call.
class DeleteClub extends ConsumerStatefulWidget {
  //the typed name is compared trimmed and case-insensitive
  static bool isClubNameConfirmed(String typed, String clubName) => typed.trim().toLowerCase() == clubName.trim().toLowerCase();

  const DeleteClub({required this.clubId, required this.clubName, super.key});

  final String clubId;
  final String clubName;

  @override
  ConsumerState<DeleteClub> createState() => _DeleteClubState();
}

class _DeleteClubState extends ConsumerState<DeleteClub> {
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

  bool get _isInputComplete => DeleteClub.isClubNameConfirmed(_nameController.text, widget.clubName) && _passwordController.text.isNotEmpty;

  Future<void> _delete() async {
    setState(() {
      _isProcessing = true;
      _errors = [];
    });

    ref.read(deleteClubRequestProvider.notifier).state =
        DeleteClubRequest(clubId: widget.clubId, clubNameConfirmation: _nameController.text.trim(), userPassword: _passwordController.text);

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
    final delta = ref.watch(deltaFontSizeProvider);
    final styles = ClubStyles.of(context, delta);
    final fieldStyle = styles.value;
    final enabled = !_isProcessing;

    //Only the title, the warning icon and the warning sentence are red; fields and other text use the normal colours.
    InputDecoration decoration(String label, IconData icon, {String? helper, Widget? suffix}) => InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          prefixIcon: Icon(icon, size: styles.iconSize),
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
        );

    final fields = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("DeleteClub".tr(), key: const Key("deleteClubTitle"), textAlign: TextAlign.center, style: styles.cardTitle.copyWith(color: styles.danger, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(warningIcon, size: styles.iconSize * 2, color: styles.danger),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text("DeleteClubWarning".tr(args: [widget.clubName]),
            key: const Key("deleteClubWarning"), textAlign: TextAlign.center, style: styles.body.copyWith(color: styles.danger, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text("DeleteClubConsequences".tr(), key: const Key("deleteClubConsequences"), textAlign: TextAlign.center, style: styles.body),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
          key: const Key("deleteClubNameField"),
          controller: _nameController,
          enabled: enabled,
          style: fieldStyle,
          decoration: decoration("DeleteClubTypeName".tr(), clubIcon),
          onChanged: (_) => setState(() {}),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
          key: const Key("deleteClubPasswordField"),
          controller: _passwordController,
          enabled: enabled,
          style: fieldStyle,
          obscureText: _isPasswordHidden,
          decoration: decoration("DeleteClubYourPassword".tr(), passwordIcon,
              helper: "DeleteClubYourPasswordHint".tr(),
              suffix: IconButton(
                icon: Icon(_isPasswordHidden ? notVisibleIcon : visibleIcon, size: styles.iconSize),
                onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
              )),
          onChanged: (_) => setState(() {}),
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
                  key: const Key("deleteClubButton"),
                  style: styles.destructiveButton,
                  onPressed: _isInputComplete ? _delete : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("DeleteClub".tr(), textAlign: TextAlign.center, style: styles.buttonLabel))),
                )),
      ),
    ];

    return BasisForm(formTitle: widget.clubName, form: ClubCard(children: fields));
  }
}
