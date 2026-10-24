import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Helpers/identity_helper.dart';

import '../../Core/DTO/Club/club_details_response.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/app_process_indicator.dart';
import '../Elements/basis_form.dart';

class ClubDetails extends ConsumerWidget {
  const ClubDetails({required this.clubId, super.key});

  final String clubId;
  final double _myElevation = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> fields = <Widget>[];

    Widget clubDetailsWidget;

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(), form: AppProcessIndicator(message: "Loading".tr()));
    }

    //clubDetailsRequestProvider is updated in the form Club_list_and_actions

    clubDetailsWidget = ref.watch(clubDetailProvider).when(
        loading: () => AppProcessIndicator(message: "Loading".tr()),
        data: (data) {
          final club = data.club;

          //if the user may not get the club details, show a message and stop
          if (club == null || !IdentityHelper.isActionAllowed(appAction: AppAction.readClubBaseInfo, allowedActions: data.allowedActions)) {
            fields.add(Text("NoAccessToClub".tr()));
          } else {
            fields.add(Text(club.clubName));

            //Go to the Club Member Management
            if (IdentityHelper.isActionAllowed(appAction: AppAction.getClubMembers, allowedActions: data.allowedActions)) {
              fields.add(
                ElevatedButton(
                  onPressed: null, //2025-03-04 member management is not yet implemented
                  child: Text("Members".tr()),
                ),
              );
            }

            //Delete Club Button
            if (IdentityHelper.isActionAllowed(appAction: AppAction.deleteClub, allowedActions: data.allowedActions)) {
              fields.add(
                ElevatedButton(
                  onPressed: null, //2024-12-01 club deletion is not yet implemented
                  child: Text("DeleteClub".tr()),
                ),
              );
            }
          }

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

    return BasisForm(formTitle: "Club".tr(), form: clubDetailsWidget);
  }

  void reloadClubDetails(WidgetRef ref) {
    return ref.refresh(clubDetailProvider);
  }
}
