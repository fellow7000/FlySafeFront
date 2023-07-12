import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Base/api_base_response.dart';

import '../../Vars/enums.dart';
import '../../Vars/providers.dart';
import '../Base/call_error.dart';
import 'check_value_request.dart';

class CheckValueResponse extends ApiBaseResponse {
  final bool isValueValid;
  final String timeStamp;

  CheckValueResponse({
    required super.resultCode,
    required this.isValueValid,
    required this.timeStamp,
    required super.errors,
  });

  factory CheckValueResponse.fromJson(Map<String, dynamic> json) {
    return CheckValueResponse(
      resultCode: getAppResultEnum(json["ResultCode"]),
      isValueValid: json["IsValueValid"] ?? false,
      timeStamp: json["TimeStamp"] ?? "",
      errors: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}


final checkValueRequestProvider = StateProvider<CheckValueRequest?>((ref) => null);

var checkValueProvider = FutureProvider.autoDispose<CheckValueResponse>((ref) {
  final checkValueRequest = ref.watch(checkValueRequestProvider);

  return ref.watch(backEndGeneric).checkValue(checkValueRequest: checkValueRequest!);
});