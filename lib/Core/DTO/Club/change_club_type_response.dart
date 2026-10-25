import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'change_club_type_request.dart';

class ChangeClubTypeResponse extends ApiBaseResponse {
  final String clubId;
  final ClubType? previousClubType;
  final ClubType? newClubType;

  ChangeClubTypeResponse({required super.resultCode, required this.clubId, this.previousClubType, this.newClubType, required super.errors});

  factory ChangeClubTypeResponse.fromJson(Map<String, dynamic> json) {
    return ChangeClubTypeResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      clubId: json["ClubId"]?.toString() ?? "",
      previousClubType: clubTypeFromJson(json["PreviousClubType"]),
      newClubType: clubTypeFromJson(json["NewClubType"]),
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }

  //accepts the numeric value or the enum name (e.g. "PublicClub")
  static ClubType? clubTypeFromJson(dynamic value) {
    if (value is int) return value >= 0 && value < ClubType.values.length ? ClubType.values[value] : null;
    if (value is String) {
      for (final type in ClubType.values) {
        if (type.name.toLowerCase() == value.toLowerCase()) return type;
      }
    }
    return null;
  }
}

final changeClubTypeRequestProvider = StateProvider<ChangeClubTypeRequest?>((ref) => null);

final changeClubTypeProvider = FutureProvider.autoDispose<ChangeClubTypeResponse>((ref) {
  final changeClubTypeRequest = ref.watch(changeClubTypeRequestProvider);

  return ref.watch(backEndClub).changeClubType(changeClubTypeRequest: changeClubTypeRequest!);
});
