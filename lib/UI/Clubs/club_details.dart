import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/club_details_response.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';

class ClubDetails extends ConsumerWidget {
  ClubDetails({required this.clubId, super.key});

  final String clubId;
  final double _myElevation = 3;

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    List<Widget> fields = <Widget>[];

    Widget clubDetailsWidget;

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(),form: AppProcessIndicator(message: "Loading".tr()));
    }

    clubDetailsWidget = ref.watch(clubDetailProvider).when(
        loading: () => AppProcessIndicator(message: "Loading".tr()),
        data: (data) {
          fields.add(Text(data.club!.clubName));
          return Column(
            children: [
              Card(
                elevation: _myElevation,
                child: Padding(
                  padding: const EdgeInsets.all(formPadding),
                  child: Column(children: fields), //Sign-in Form
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: formPadding)),
            ],
          );
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

  void reloadClubDetails(WidgetRef ref) {
    return ref.refresh(clubDetailProvider);
  }

}