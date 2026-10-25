import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'club_member_dto.dart';
import 'get_club_members_request.dart';

class GetClubMembersResponse extends ApiBaseResponse {
  final String clubId;
  final bool canAddMember;
  final List<ClubMemberDTO> members; //already sorted by the server

  GetClubMembersResponse({required super.resultCode, required this.clubId, this.canAddMember = false, this.members = const [], required super.errors});

  //a success body may come without ResultCode, so the HTTP status is the fallback
  factory GetClubMembersResponse.fromJson(Map<String, dynamic> json, {int statusCode = 200}) {
    return GetClubMembersResponse(
      resultCode: getAppResultEnum(json["ResultCode"] ?? statusCode),
      clubId: json["ClubId"]?.toString() ?? "",
      canAddMember: json["CanAddMember"] == true,
      members: List.of(json["Members"] ?? []).map((m) => ClubMemberDTO.fromJson(m)).toList(),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

//the member list of one club; invalidate it after adding, changing or removing a member
final getClubMembersProvider = FutureProvider.autoDispose.family<GetClubMembersResponse, String>((ref, clubId) {
  return ref.watch(backEndClub).getClubMembers(getClubMembersRequest: GetClubMembersRequest(clubId: clubId));
});
