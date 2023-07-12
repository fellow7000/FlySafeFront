import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_requrest.dart';
import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';

class AuthentificationResponse extends ApiBaseResponse {
  final String accessToken;
  final LogAs logAs;
  final String hash;

  AuthentificationResponse({
    required super.resultCode,
    required this.accessToken,
    required this.logAs,
    required this.hash,
    required super.errors,
  });

  factory AuthentificationResponse.fromJson(Map<String, dynamic> json) {
    return AuthentificationResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      accessToken: json["AccessToken"],
      logAs: LogAs.values[json["LogAs"]],
      hash: json["Hash"] ?? "",
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


//these providers are being used for
// final startUpAuthentificationRequestProvider = StateProvider<AuthentificationRequest?>((ref) => null);
//
// var startUpSignInProvider = FutureProvider.autoDispose<AuthentificationResponse>((ref) {
//   final authentificationRequest = ref.watch(startUpAuthentificationRequestProvider);
//
//   return ref.watch(backEndUser).signIn(authentificationRequest: authentificationRequest!);
// });

final authentificationRequestProvider = StateProvider<AuthentificationRequest?>((ref) => null);

var signInProvider = FutureProvider.autoDispose<AuthentificationResponse>((ref) {
  final authentificationRequest = ref.watch(authentificationRequestProvider);

  return ref.watch(backEndUser).signIn(authentificationRequest: authentificationRequest!);
});