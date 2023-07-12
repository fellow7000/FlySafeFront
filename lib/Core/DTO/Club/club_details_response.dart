import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'club_details_request.dart';
import 'club_dto.dart';

class ClubDetailsResponse extends ApiBaseResponse {
  final ClubDTO? club;

  ClubDetailsResponse({
    required super.resultCode,
    required this.club,
    required super.errors});

  factory ClubDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ClubDetailsResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      club: json["ClubID"]??"",
      errors: List.of(json["Errors"]??[]).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final clubDetailsRequestProvider = StateProvider<ClubDetailsRequest?>((ref) => null);

var clubDetailProvider = FutureProvider.autoDispose<ClubDetailsResponse>((ref) {
  final clubDetailsRequest = ref.watch(clubDetailsRequestProvider);

  return ref.watch(backEndClub).getClubDetails(clubDetailsRequest: clubDetailsRequest!);
});