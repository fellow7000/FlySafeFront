import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/registration_request.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';

class RegistrationResponse extends ApiBaseResponse {
  final String userName;
  final String accessToken;
  final String userPasswordHash;
  final String clubName;
  final LogAs logAs;

  RegistrationResponse({
    required super.resultCode,
    required this.userName,
    required this.accessToken,
    required this.userPasswordHash,
    required this.clubName,
    required this.logAs,
    required super.errors,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      userName: json["UserName"] ?? "",
      accessToken: json["AccessToken"] ?? "",
      userPasswordHash: json["UserPasswordHash"] ?? "",
      clubName: json["ClubName"] ?? "",
      logAs: LogAs.values[json["LogAs"]],
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


final registrationRequestProvider = StateProvider<RegistrationRequest?>((ref) => null);

var registrationProvider = FutureProvider.autoDispose<RegistrationResponse>((ref) {
  final registrationRequest = ref.watch(registrationRequestProvider);

  return ref.watch(backEndUser).signUp(registrationRequest: registrationRequest!);
});