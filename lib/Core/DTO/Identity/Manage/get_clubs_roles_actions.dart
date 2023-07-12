import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Generic/allowed_actions_dto.dart';

import '../../../Vars/enums.dart';
import '../../../Vars/providers.dart';
import '../../Base/api_base_response.dart';
import '../../Base/call_error.dart';
import '../../Club/club_and_role_dto.dart';

class GetClubsRolesActionsResponse extends ApiBaseResponse {
  final AllowedActionsDTO allowedActions; //these are allowed actions for the club manager - eg. add / join club but not the actions in the club itself.
  final List<ClubAndRoleDTO> clubAndRoleDTOList;

  GetClubsRolesActionsResponse({
    required super.resultCode,
    required this.allowedActions,
    required this.clubAndRoleDTOList,
    required super.errors,
  });

  factory GetClubsRolesActionsResponse.fromJson(Map<String, dynamic> json) {
    return GetClubsRolesActionsResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      allowedActions: AllowedActionsDTO.fromJson(json["AllowedActions"]),
      clubAndRoleDTOList: List.of(json["Clubs"]).map((i) => ClubAndRoleDTO.fromJson(i)).toList(),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final getClubsRolesActionsProvider = FutureProvider.autoDispose<GetClubsRolesActionsResponse>((ref) {
  return ref.watch(backEndUser).getClubsRolesActions();
});