import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/get_clubs_roles_actions.dart';
import 'package:fs_front/Helpers/general_helper.dart';
import 'package:fs_front/UI/Clubs/club_list_and_actions.dart';
import 'package:fs_front/UI/Elements/app_process_indicator.dart';

import '../../Core/DTO/Generic/allowed_actions_dto.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Elements/api_error_tile_retry.dart';
import '../Elements/basis_form.dart';

class ClubManager extends ConsumerStatefulWidget {
  const ClubManager({super.key});

  @override
  ConsumerState<ClubManager> createState() => ClubManagerWidget();
}

class ClubManagerWidget extends ConsumerState<ClubManager> {

  static const double myTopPadding = 0;
  static const double divIntent = 10;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      Widget profileWidget = Container();

      requestedActions = [GeneralHelper.capitalizeFirstCharacter(AppAction.createClub.name), GeneralHelper.capitalizeFirstCharacter(AppAction.joinClub.name)];

      profileWidget = ref.watch(getClubsRolesActionsProvider).when(
          loading: () => AppProcessIndicator(message: "Loading".tr()),
          skipLoadingOnRefresh: false,
          error: (err, stack) =>
              ApiErrorTileRetry(
                err: err,
                errorMessage: "BackEndComError".tr(),
                errorStack: stack,
                tapToRetryHint: appPlatform == EndDevice.web ? "ClickToRetry".tr() : "TapToRetry".tr(),
                deltaSize: ref.watch(deltaFontSizeProvider),
                retryCallBack: () => reloadClubsRolesActions(ref),
              ),
          data: (clubsRolesActions) => _toClubRolesActions(clubsRolesActions, ref)
      );

      return BasisForm(formTitle: "Clubs".tr(), form: profileWidget);
    });
  }

  void reloadClubsRolesActions(WidgetRef ref) {
    return ref.refresh(getClubsRolesActionsProvider);
  }

  ClubListAndActions _toClubRolesActions(GetClubsRolesActionsResponse clubListAndActions, WidgetRef ref) {
    clubListAndActions.clubAndRoleDTOList.sort((a, b) => a.clubName.compareTo(b.clubName));
    return ClubListAndActions(clubsRolesActionsResponse: clubListAndActions);
  }

}