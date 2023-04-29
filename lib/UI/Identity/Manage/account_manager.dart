import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:fs_front/Core/Vars/exceptions.dart';
import 'package:fs_front/UI/Elements/basis_form.dart';
import 'package:fs_front/UI/Identity/Manage/user_profile.dart';

import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../Elements/api_error_tile_retry.dart';
import '../../Elements/app_process_indicator.dart';

class AccountManager extends ConsumerWidget {
  const AccountManager({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //orientation build is needed to prevent framework error on orientation change
    return OrientationBuilder(builder: (context, orientation) {
      Widget profileWidget = Container();

      if (loadUserOrClubProfile) {
        switch (ref.watch(authStateProvider)) {
          case LogAs.user:
            profileWidget = ref.watch(getUserProfileProvider).when(
                loading: () => AppProcessIndicator(message: "Loading".tr()),
                skipLoadingOnRefresh: false,
                error: (err, stack) =>
                    ApiErrorTileRetry(
                      err: err,
                      errorMessage: "BackEndComError".tr(),
                      errorStack: stack,
                      tapToRetryHint: appPlatform == EndDevice.web ? "ClickToRetry".tr() : "TapToRetry".tr(),
                      deltaSize: ref.watch(deltaFontSizeProvider),
                      retryCallBack: () => reloadProfile(ref),
                    ),
                data: (userProfile) => _toUserProfile(userProfile, ref)
            );
            break;

          case LogAs.club:
            UserProfileResponse clubProfile = UserProfileResponse(success: true,
                userName: ref
                    .read(userOrClubNameProvider.notifier)
                    .state,
                email: "",
                createdOn: DateTime.now().toUtc().toIso8601String(),
                clubAndRoleDTOList: [],
                errors: []);
            profileWidget = UserOrClubProfile(userProfile: clubProfile);
            break;

          case LogAs.none:
            profileWidget = ApiErrorTileRetry(
              err: Unauthorised(),
              errorMessage: "BackEndComError".tr(),
              errorStack: null,
              tapToRetryHint: clickToRetry.tr(),
              deltaSize: ref.watch(deltaFontSizeProvider),
            ); //TODO: Placeholder
            break;

          default:
            profileWidget = Container(); //just a place holder, default shall never been reached!
            break;
        }
      }

      return BasisForm(formTitle: "ManageYourAccount".tr(), form: profileWidget);
    });
  }

  void reloadProfile(WidgetRef ref) {
    loadUserOrClubProfile = true;
    return ref.refresh(getUserProfileProvider);
  }

  UserOrClubProfile _toUserProfile(UserProfileResponse userProfile, WidgetRef ref) {
    userProfile.clubAndRoleDTOList.sort((a, b) => a.clubName.compareTo(b.clubName));
    return UserOrClubProfile(userProfile: userProfile);
  }
}