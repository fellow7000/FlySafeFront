import 'package:fs_front/Core/Vars/enums.dart';

import 'call_error.dart';

class ApiBaseResponse {
  AppResultCode resultCode;
  final List<CallError> errors;

  ApiBaseResponse({required this.resultCode, required this.errors});
}