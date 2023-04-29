import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Vars/providers.dart';
import '../../Base/api_base_response.dart';
import '../../Base/call_error.dart';
import 'change_user_password_request.dart';

class ChangeUserPasswordResponse extends ApiBaseResponse {
  final String newAccessToken;
  final String newUserPasswordHash;

  ChangeUserPasswordResponse({required super.success,
    required this.newAccessToken,
    required this.newUserPasswordHash,
    required super.errors});

  factory ChangeUserPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangeUserPasswordResponse(
      success: json["Success"],
      newAccessToken: json["NewAccessToken"]??"",
      newUserPasswordHash: json["NewUserPasswordHash"]??"",
      errors: List.of(json["Errors"]??[]).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final changeUserPasswordRequestProvider = StateProvider<ChangeUserPasswordRequest?>((ref) => null);

var changeUserPasswordProvider = FutureProvider.autoDispose<ChangeUserPasswordResponse>((ref) {
  final changeUserPasswordRequest = ref.watch(changeUserPasswordRequestProvider);

  return ref.watch(backEndUser).changeUserPassword(changeUserPasswordRequest: changeUserPasswordRequest!);
});