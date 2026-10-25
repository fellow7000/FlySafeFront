import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/change_club_password_request.dart';
import '../../Core/DTO/Club/change_club_password_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Helpers/club_error_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/basis_form.dart';
import '../Elements/password_change_fields.dart';
import '../Themes/app_themes.dart';

const int clubPasswordMaxLength = 100;

class ChangeClubPassword extends ConsumerStatefulWidget {
  const ChangeClubPassword({required this.clubId, super.key});

  final String clubId;

  @override
  ConsumerState<ChangeClubPassword> createState() => _ChangeClubPasswordState();
}

class _ChangeClubPasswordState extends ConsumerState<ChangeClubPassword> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);
  final _isChangePossibleProvider = StateProvider.autoDispose<bool>((ref) => false);

  List<CallError> _callErrors = [];

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final isProcessing = formState == AppFormState.processing;
    final isError = formState == AppFormState.httpError || formState == AppFormState.exception || formState == AppFormState.resultFailed;
    final textHeadlineSmall = Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: fontSizeDelta, color: Colors.white);

    final fields = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("ChangeClubPassword".tr(),
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)),
      ),
      PasswordChangeFields(
        currentController: _currentController,
        newController: _newController,
        confirmController: _confirmController,
        currentLabel: "CurrentClubPassword".tr(),
        newLabel: "NewClubPassword".tr(),
        confirmLabel: "ConfirmNewClubPassword".tr(),
        minLength: 0,
        maxLength: clubPasswordMaxLength,
        allowEmptyCurrent: true,
        enabled: !isProcessing,
        onValidityChanged: (valid) => ref.read(_isChangePossibleProvider.notifier).state = valid,
      ),
      Padding(padding: const EdgeInsets.only(top: 5), child: Text("ClbPswEmpty".tr(), style: Theme.of(context).textTheme.bodySmall)),
      if (isError) ApiErrorMessages(callErrors: _callErrors, deltaFontSize: fontSizeDelta),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: isProcessing
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: primaryActionButtonDefDisabledColor,
                    backgroundColor: Theme.of(context).brightness == Brightness.light ? primaryActionButtonDefEnabledColorLight : null,
                  ),
                  onPressed: ref.watch(_isChangePossibleProvider) ? _changePassword : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(fit: BoxFit.scaleDown, child: Text("ChangePassword".tr(), textAlign: TextAlign.center, style: textHeadlineSmall))),
                )),
      ),
    ];

    return BasisForm(
      formTitle: "ChangeClubPassword".tr(),
      form: Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(15), child: Column(children: fields))),
    );
  }

  Future<void> _changePassword() async {
    _callErrors = [];
    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(changeClubPasswordRequestProvider.notifier).state = ChangeClubPasswordRequest(
        clubId: widget.clubId, oldClubPassword: _currentController.text, newClubPassword: _newController.text);

    try {
      final ChangeClubPasswordResponse response = await ref.read(changeClubPasswordProvider.future);
      if (!mounted) return;
      if (response.resultCode == AppResultCode.ok) {
        ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
        AppHelper.showSnack(context: context, message: "ClubPasswordChanged".tr());
        Navigator.of(context).pop(true);
      } else {
        _callErrors = ClubErrorHelper.localize(response.errors);
        ref.read(_formStateProvider.notifier).state = AppFormState.resultFailed;
      }
    } catch (_) {
      if (!mounted) return;
      _callErrors = [BackEndCall.callExceptionError];
      ref.read(_formStateProvider.notifier).state = AppFormState.httpError;
    }
  }
}
