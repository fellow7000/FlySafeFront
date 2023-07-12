import '../../Vars/enums.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'club_dto.dart';

//for api call clubList
class GetClubsResponse extends ApiBaseResponse {
  final List<ClubDTO> clubList;

  GetClubsResponse({
    required super.resultCode,
    required this.clubList,
    required super.errors,
  });

  factory GetClubsResponse.fromJson(Map<String, dynamic> json) {
    var clubList = json["ClubList"] as List;
    var errorList = json["Errors"] as List;

    return GetClubsResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubList: clubList.map((c) => ClubDTO.fromJson(c)).toList(),
      errors: errorList.map((e) => CallError.fromJson(e)).toList(),
    );
  }
}
