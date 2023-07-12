import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/api_base_response.dart';
import '../Base/call_error.dart';
import 'check_username_free_request.dart';

class CheckUserNameFreeResponse extends ApiBaseResponse {
  final bool userNameIsFree;

  CheckUserNameFreeResponse({
    required super.resultCode,
    required this.userNameIsFree,
    required super.errors,
  });

  factory CheckUserNameFreeResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserNameFreeResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      userNameIsFree: json["UserNameIsFree"] ?? false,
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


final checkUserNameFreeRequestProvider = StateProvider<CheckUserNameFreeRequest?>((ref) => null);

var checkUserNameFreeProvider = FutureProvider.autoDispose<CheckUserNameFreeResponse>((ref) {
  final checkUserNameFreeRequest = ref.watch(checkUserNameFreeRequestProvider);

  return ref.watch(backEndUser).checkUserNameFree(checkUserNameFreeRequest: checkUserNameFreeRequest!);
});