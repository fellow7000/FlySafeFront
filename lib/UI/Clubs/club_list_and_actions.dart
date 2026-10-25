import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Helpers/identity_helper.dart';
import 'package:fs_front/UI/Clubs/add_club.dart';
import 'package:fs_front/UI/Elements/app_process_indicator.dart';

import '../../Core/DTO/Club/club_details_request.dart';
import '../../Core/DTO/Club/club_details_response.dart';
import '../../Core/DTO/Identity/Manage/get_clubs_roles_actions.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/general_helper.dart';
import '../Elements/basis_form.dart';
import 'club_details.dart';
import 'club_ui.dart';
import 'join_club.dart';

///Form to display the list of clubs where the user is a member, manager, owner etc plus several actions (create a new club, join a club)
class ClubListAndActions extends ConsumerWidget {

  static const double divIntent = 10;
  final GetClubsRolesActionsResponse clubsRolesActionsResponse;

  ClubListAndActions({ required this.clubsRolesActionsResponse, super.key}) {
    clubsRolesActionsResponse.clubAndRoleDTOList.sort((a, b) => a.clubName.compareTo(b.clubName));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ClubStyles.of(context, ref.watch(deltaFontSizeProvider));

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(), form: AppProcessIndicator(message: "Loading".tr()));
    }

    const divider = Divider(indent: divIntent, endIndent: divIntent);
    final fields = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("YourClubs".tr(), textAlign: TextAlign.center, style: styles.cardTitle),
      ),
    ];

    final clubs = clubsRolesActionsResponse.clubAndRoleDTOList;
    if (clubs.isEmpty) {
      fields.add(Padding(padding: const EdgeInsets.all(10), child: Text("NoClubsYet".tr(), textAlign: TextAlign.center, style: styles.body)));
    }

    for (final club in clubs) {
      if (club != clubs.first) fields.add(divider);
      fields.add(ListTile(
        leading: Icon(clubIcon, size: styles.iconSize),
        title: Text(club.clubName, style: styles.value),
        subtitle: club.roles.isEmpty ? null : ClubRolesText(roleNames: club.roles.map((r) => r.item2).toList(), style: styles.label),
        trailing: Icon(chevronExpand, size: styles.iconSize),
        onTap: () => _showClubDetails(clubId: club.clubID, ref: ref, context: context),
      ));
    }

    //Add Club
    if (IdentityHelper.isActionAllowed(appAction: AppAction.createClub, allowedActions: clubsRolesActionsResponse.allowedActions)) {
      fields.add(divider);
      fields.add(ListTile(
        leading: Icon(addObjectIcon, size: styles.iconSize),
        title: Text("AddClub".tr(), style: styles.value),
        trailing: Icon(chevronExpand, size: styles.iconSize),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClub())),
      ));
    }

    //Join Club
    if (IdentityHelper.isActionAllowed(appAction: AppAction.joinClub, allowedActions: clubsRolesActionsResponse.allowedActions)) {
      fields.add(divider);
      fields.add(ListTile(
        leading: Icon(joinClubIcon, size: styles.iconSize),
        title: Text("JoinClub".tr(), style: styles.value),
        trailing: Icon(chevronExpand, size: styles.iconSize),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinClub())),
      ));
    }

    return ClubCard(children: fields);
  }

  void _showClubDetails({required String clubId, required WidgetRef ref, required BuildContext context}) {
    ref.read(clubDetailsRequestProvider.notifier).state = ClubDetailsRequest(clubId: clubId, requestedActions: GeneralHelper.formActionList([
      AppAction.readClubBaseInfo,
      AppAction.editClubBaseInfo,
      AppAction.deleteClub,
      AppAction.changeClubPassword,
      AppAction.getClubMembers,
      AppAction.leaveClub,
      AppAction.handoverClub //2023-07-17 no club hand-over in the version 4.0, so this is just a placeholder.
    ])); 
    Navigator.push(context, MaterialPageRoute(builder: (context) => ClubDetails(clubId: clubId)));
  }

}