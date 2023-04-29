import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'join_club_request.dart';

class JoinClubResponse extends ApiBaseResponse {

  JoinClubResponse({
    required bool success,
    required List<CallError> errors,
  }) : super(success: success, errors: errors);

  factory JoinClubResponse.fromJson(Map<String, dynamic> json) {
    return JoinClubResponse(
      success: json["Success"],
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final joinClubRequestProvider =
StateProvider<JoinClubRequest?>((ref) => null);

var joinClubProvider = FutureProvider.autoDispose<JoinClubResponse>((ref) {
  final joinClubRequest = ref.watch(joinClubRequestProvider);

  return ref.watch(backEndClub).joinClub(joinClubRequest: joinClubRequest!);
});