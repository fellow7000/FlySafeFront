import 'call_error.dart';

class ApiBaseResponse {
  final bool success;
  final List<CallError> errors;

  ApiBaseResponse({required this.success, required this.errors});
}