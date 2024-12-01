import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Generic/allowed_actions_dto.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'club_details_request.dart';
import 'club_dto.dart';

class ClubDetailsResponse extends ApiBaseResponse {
  final ClubDTO? club;
  final AllowedActionsDTO allowedActions;

  ClubDetailsResponse({
    required super.resultCode,
    required this.club,
    required this.allowedActions,
    required super.errors});

  factory ClubDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ClubDetailsResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      club: ClubDTO.fromJson(json["Club"]),
      allowedActions: AllowedActionsDTO.fromJson(json["AllowedActions"]),
      errors: List.of(json["Errors"]??[]).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final clubDetailsRequestProvider = StateProvider<ClubDetailsRequest?>((ref) => null);

var clubDetailProvider = FutureProvider.autoDispose<ClubDetailsResponse>((ref) {
  final clubDetailsRequest = ref.watch(clubDetailsRequestProvider);

  return ref.watch(backEndClub).getClubDetails(clubDetailsRequest: clubDetailsRequest!);
});