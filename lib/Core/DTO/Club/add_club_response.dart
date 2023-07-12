import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';

import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'add_club_request.dart';

class AddClubResponse extends ApiBaseResponse {
  final String clubID;

  AddClubResponse({
    required super.resultCode,
    required this.clubID,
    required super.errors});

  factory AddClubResponse.fromJson(Map<String, dynamic> json) {
    return AddClubResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubID: json["ClubID"]??"",
      errors: List.of(json["Errors"]??[]).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final addClubRequestProvider = StateProvider<AddClubRequest?>((ref) => null);

var addClubProvider = FutureProvider.autoDispose<AddClubResponse>((ref) {
  final addClubRequest = ref.watch(addClubRequestProvider);

  return ref.watch(backEndClub).createClub(addClubRequest: addClubRequest!);
});