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
import '../Themes/app_themes.dart';
import 'club_details.dart';
import 'join_club.dart';

///Form to display the list of clubs where the user is a member, manager, owner etc plus several actions (create a new club, join a club)
class ClubListAndActions extends ConsumerWidget {

  static const double myTopPadding = 0;
  static const double divIntent = 10;
  final GetClubsRolesActionsResponse clubsRolesActionsResponse;

  ClubListAndActions({ required this.clubsRolesActionsResponse, super.key}) {
    clubsRolesActionsResponse.clubAndRoleDTOList.sort((a, b) => a.clubName.compareTo(b.clubName));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;

    if (ref.watch(getUserProfileProvider).isRefreshing) {
      return BasisForm(formTitle: "Clubs".tr(),form: AppProcessIndicator(message: "Loading".tr()));
    }

    List<Widget> fields = <Widget>[];

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("ClubsManager".tr(),
          textAlign: TextAlign.center, style: textStyleHeadlineSmall),
    ));

    fields.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: DataTable(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            columns: [
              DataColumn(label: Text('Club'.tr(), style: textStyleTitleMedium.copyWith(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('Role'.tr(), style: textStyleTitleMedium.copyWith(fontWeight: FontWeight.bold))),
              //DataColumn(label: Text('', style: textStyleTitleMedium.copyWith(fontWeight: FontWeight.bold))),
            ],
            rows: clubsRolesActionsResponse.clubAndRoleDTOList.asMap().entries.map((entry) {
              final index = entry.key;
              final clubAndRoleDTO = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(clubAndRoleDTO.clubName, style: textStyleTitleMedium)),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: clubAndRoleDTO.roles.map((roleTuple) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(roleTuple.item2.tr(), style: textStyleTitleMedium),
                            //IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClubDetails(clubId: clubAndRoleDTO.clubID,))), icon: Icon(chevronExpand, size: iconSize))
                            IconButton(onPressed: () => _showClubDetails(clubId: clubAndRoleDTO.clubID, ref: ref, context: context), icon: Icon(chevronExpand, size: iconSize))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  //DataCell(IconButton(icon: Icon(chevronExpand, size: iconSize), onPressed: null,)),
                ],
                color: index.isOdd? null : WidgetStateProperty.all<Color>(evenRowColor),
              );
            }).toList(),
          ),
        )
    );

    //Add Club
    if (IdentityHelper.isActionAllowed(appAction: AppAction.createClub, allowedActions: clubsRolesActionsResponse.allowedActions)) {
      fields.add(const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ));

      fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: ListTile(
          leading: Icon(addObjectIcon, size: iconSize),
          title: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text("AddClub".tr(), style: textStyleTitleLarge,))),
          trailing: Icon(chevronExpand, size: iconSize),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClub())),
        ),
      ));
    }

    //Join Club
    if (IdentityHelper.isActionAllowed(appAction: AppAction.joinClub, allowedActions: clubsRolesActionsResponse.allowedActions)) {
      fields.add(const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ));

      fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: ListTile(
          leading: Icon(joinClubIcon, size: iconSize),
          title: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text("JoinClub".tr(), style: textStyleTitleLarge,))),
          trailing: Icon(chevronExpand, size: iconSize),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinClub())),
        ),
      ));
    }

    Widget clubsManagerWidget = Column(
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(formPadding),
            child: Column(children: fields), //Sign-in Form
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: formPadding)),
      ],
    );

    return Column(
      children: [
        clubsManagerWidget,
        const Padding(padding: EdgeInsets.only(top: 15)),
      ],
    );

  }

  void _showClubDetails({required String clubId, required WidgetRef ref, required BuildContext context}) {
    ref.read(clubDetailsRequestProvider.notifier).state = ClubDetailsRequest(clubId: clubId, requestedActions: GeneralHelper.formActionList([
      AppAction.readClubBaseInfo,
      AppAction.editClubBaseInfo,
      AppAction.deleteClub,
      AppAction.changeClubPassword,
      AppAction.getClubMembers,
      AppAction.handoverClub //2023-07-17 no club hand-over in this version, so this is just a placeholder.
    ])); 
    Navigator.push(context, MaterialPageRoute(builder: (context) => ClubDetails(clubId: clubId)));
  }

}