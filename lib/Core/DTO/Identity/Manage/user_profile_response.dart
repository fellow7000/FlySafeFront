import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Vars/enums.dart';
import '../../../Vars/providers.dart';
import '../../Base/api_base_response.dart';
import '../../Base/call_error.dart';
import '../../Club/club_and_role_dto.dart';

class UserProfileResponse extends ApiBaseResponse {
  final String userName;
  final String email;
  final String createdOn;
  //final List<ClubAndRoleDTO> clubAndRoleDTOList;

  UserProfileResponse({
    required super.resultCode,
    required this.userName,
    required this.email,
    required this.createdOn,
    //required this.clubAndRoleDTOList,
    required super.errors,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      userName: json["UserName"],
      email: json["Email"],
      createdOn: json["CreatedOn"],
      //clubAndRoleDTOList: List.of(json["Clubs"]).map((i) => ClubAndRoleDTO.fromJson(i)).toList(),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final getUserProfileProvider = FutureProvider.autoDispose<UserProfileResponse>((ref) {
  return ref.watch(backEndUser).getUserProfile();
});