import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_request.dart';

import '../../../Vars/providers.dart';
import '../../Base/api_base_response.dart';
import '../../Base/call_error.dart';

class DeleteUserAccountResponse extends ApiBaseResponse {

  DeleteUserAccountResponse({required super.success,
    required super.errors});

  factory DeleteUserAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteUserAccountResponse(
      success: json["Success"],
      errors: List.of(json["Errors"]??[]).map((e) => CallError.fromJson(e)).toList(),
    );
  }
}

final deleteUserAccountRequestProvider = StateProvider<DeleteUserAccountRequest?>((ref) => null);

var deleteUserAccountProvider = FutureProvider.autoDispose<DeleteUserAccountResponse>((ref) {
  final deleteUserAccountRequest = ref.watch(deleteUserAccountRequestProvider);

  return ref.watch(backEndUser).deleteUserAccount(deleteUserAccountRequest: deleteUserAccountRequest!);
});