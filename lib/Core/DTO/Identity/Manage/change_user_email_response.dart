import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Vars/enums.dart';
import '../../../Vars/providers.dart';
import '../../Base/api_base_response.dart';
import '../../Base/call_error.dart';
import 'change_user_email.request.dart';

class ChangeUserEmailResponse extends ApiBaseResponse {
  final String newEmail;

  ChangeUserEmailResponse({
    required super.resultCode,
    required this.newEmail,
    required super.errors,
  });

  factory ChangeUserEmailResponse.fromJson(Map<String, dynamic> json) {
    return ChangeUserEmailResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      newEmail: json["NewEmail"] ?? "",
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


final changeUserEmailRequestProvider = StateProvider<ChangeUserEmailRequest?>((ref) => null);

var changeUserEmailProvider = FutureProvider.autoDispose<ChangeUserEmailResponse>((ref) {
  final changeUserEmailRequest = ref.watch(changeUserEmailRequestProvider);

  return ref.watch(backEndUser).changeUserEmail(changeUserEmailRequest: changeUserEmailRequest!);
});