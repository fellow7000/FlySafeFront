import 'call_error.dart';

class CallResponse<T> {
  final bool success;
  final int statusCode;
  T? body;
  List<CallError>? callError = [];

  CallResponse({required this.success, required this.statusCode, this.body, this.callError});
  CallResponse.reduced({required this.success, required this.callError, this.statusCode = -1}) {
    this.body = null;
  }

  factory CallResponse.fromJson(Map<String, dynamic> json) {
    return CallResponse.reduced(
      success: json["success"].toLowerCase() == 'true',
      callError: List.of(json["Errors"] ?? []).map((e) => CallError.fromJson(e)).toList(),
    );
  }
//
}