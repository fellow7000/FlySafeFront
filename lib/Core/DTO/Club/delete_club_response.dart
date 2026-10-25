import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'delete_club_request.dart';

class DeleteClubResponse extends ApiBaseResponse {
  final String clubId;
  final DateTime? deletedOn;

  DeleteClubResponse({required super.resultCode, required this.clubId, required this.deletedOn, required super.errors});

  factory DeleteClubResponse.fromJson(Map<String, dynamic> json) {
    return DeleteClubResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubId: json["ClubId"]?.toString() ?? "",
      deletedOn: json["DeletedOn"] == null ? null : DateTime.tryParse(json["DeletedOn"].toString()),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final deleteClubRequestProvider = StateProvider<DeleteClubRequest?>((ref) => null);

final deleteClubProvider = FutureProvider.autoDispose<DeleteClubResponse>((ref) {
  final deleteClubRequest = ref.watch(deleteClubRequestProvider);

  return ref.watch(backEndClub).deleteClub(deleteClubRequest: deleteClubRequest!);
});
