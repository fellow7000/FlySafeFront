import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'leave_club_request.dart';

class LeaveClubResponse extends ApiBaseResponse {
  final String clubId;

  LeaveClubResponse({required super.resultCode, required this.clubId, required super.errors});

  factory LeaveClubResponse.fromJson(Map<String, dynamic> json) {
    return LeaveClubResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubId: json["ClubId"]?.toString() ?? "",
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final leaveClubRequestProvider = StateProvider<LeaveClubRequest?>((ref) => null);

final leaveClubProvider = FutureProvider.autoDispose<LeaveClubResponse>((ref) {
  final leaveClubRequest = ref.watch(leaveClubRequestProvider);

  return ref.watch(backEndClub).leaveClub(leaveClubRequest: leaveClubRequest!);
});
