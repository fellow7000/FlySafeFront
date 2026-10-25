import '../../Vars/enums.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';

//Response of addclubmember, setclubmemberrole and removeclubmember. addclubmember returns only the ClubId.
class ClubMemberChangeResponse extends ApiBaseResponse {
  final String clubId;
  final String? userId;
  final String? role;

  ClubMemberChangeResponse({required super.resultCode, this.clubId = "", this.userId, this.role, required super.errors});

  //a success body may come without ResultCode, so the HTTP status is the fallback
  factory ClubMemberChangeResponse.fromJson(Map<String, dynamic> json, {int statusCode = 200}) {
    return ClubMemberChangeResponse(
      resultCode: getAppResultEnum(json["ResultCode"] ?? statusCode),
      clubId: json["ClubId"]?.toString() ?? "",
      userId: json["UserId"]?.toString(),
      role: json["Role"]?.toString(),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}
