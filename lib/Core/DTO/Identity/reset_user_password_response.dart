import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/reset_user_password_request.dart';
import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';

class ResetUserPasswordResponse extends ApiBaseResponse {
  final String email;

  ResetUserPasswordResponse({
    required super.resultCode,
    required this.email,
    required super.errors,
  });

  factory ResetUserPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetUserPasswordResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      email: json["Email"],
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


final resetUserPasswordRequestProvider = StateProvider<ResetUserPasswordRequest?>((ref) => null);

final resetUserPasswordProvider = FutureProvider.autoDispose<ResetUserPasswordResponse>((ref) {
  final resetUserPasswordRequest = ref.watch(resetUserPasswordRequestProvider);

  return ref.watch(backEndUser).requestUserPasswordReset(resetUserPasswordRequest: resetUserPasswordRequest!);
});