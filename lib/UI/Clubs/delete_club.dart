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
import '../Themes/app_themes.dart';

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
    final iconSize = appIconBasisSize + delta;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final red = isLight ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark;
    final redDisabled = isLight ? primaryWarningButtonDisabledColorLight : primaryWarningButtonDisabledColorDark;
    final fieldStyle = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: delta);
    final labelStyle = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: delta, color: red);
    final enabled = !_isProcessing;

    InputDecoration decoration(String label, IconData icon, {Widget? suffix}) => InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          floatingLabelStyle: TextStyle(color: red),
          prefixIcon: Icon(icon, size: iconSize, color: red),
          suffixIcon: suffix,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: red.withValues(alpha: 0.6))),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: red, width: 2)),
          border: OutlineInputBorder(borderSide: BorderSide(color: red)),
        );

    final fields = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("DeleteClub".tr(),
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: delta, color: red)),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(Icons.warning_amber_rounded, size: iconSize * 2, color: red),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text("DeleteClubWarning".tr(args: [widget.clubName]), textAlign: TextAlign.center, style: textStyleTitleMedium.copyWith(color: red, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text("DeleteClubConsequences".tr(), textAlign: TextAlign.center, style: textStyleTitleMedium.copyWith(color: red)),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
          controller: _nameController,
          enabled: enabled,
          style: fieldStyle,
          cursorColor: red,
          decoration: decoration("DeleteClubTypeName".tr(), clubIcon),
          onChanged: (_) => setState(() {}),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
          controller: _passwordController,
          enabled: enabled,
          style: fieldStyle,
          cursorColor: red,
          obscureText: _isPasswordHidden,
          decoration: decoration("DeleteClubYourPassword".tr(), passwordIcon,
              suffix: IconButton(
                icon: Icon(_isPasswordHidden ? notVisibleIcon : visibleIcon, size: iconSize, color: red),
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
                  style: ElevatedButton.styleFrom(backgroundColor: red, disabledBackgroundColor: redDisabled),
                  onPressed: _isInputComplete ? _delete : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("DeleteClub".tr(), textAlign: TextAlign.center, style: textStyleHeadlineSmall.copyWith(color: _isInputComplete ? Colors.white : null)))),
                )),
      ),
    ];

    return BasisForm(
      formTitle: "Club".tr(),
      form: Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(15), child: Column(children: fields))),
    );
  }
}
