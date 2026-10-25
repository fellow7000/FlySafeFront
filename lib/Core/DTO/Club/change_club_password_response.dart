import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'change_club_password_request.dart';

class ChangeClubPasswordResponse extends ApiBaseResponse {
  final String clubId;

  ChangeClubPasswordResponse({required super.resultCode, required this.clubId, required super.errors});

  factory ChangeClubPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangeClubPasswordResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubId: json["ClubId"]?.toString() ?? "",
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final changeClubPasswordRequestProvider = StateProvider<ChangeClubPasswordRequest?>((ref) => null);

final changeClubPasswordProvider = FutureProvider.autoDispose<ChangeClubPasswordResponse>((ref) {
  final changeClubPasswordRequest = ref.watch(changeClubPasswordRequestProvider);

  return ref.watch(backEndClub).changeClubPassword(changeClubPasswordRequest: changeClubPasswordRequest!);
});
