import 'package:flutter/cupertino.dart';
import 'package:fs_front/Core/DTO/Generic/check_value_request.dart';

import 'package:fs_front/Core/DTO/Generic/check_value_response.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/DTO/Base/call_response.dart';
import '../../../Core/Vars/enums.dart';
import '../backend_call.dart';
import 'i_api_generic.dart';

class ApiGeneric implements IApiGeneric {
  final Uri webHostUri;

  ApiGeneric({required this.webHostUri});

  @override
  Future<CheckValueResponse> checkValue({required CheckValueRequest checkValueRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri).callAPI(
        callTypeAPI: CallTypeAPI.post,
        body: checkValueRequest,
        apiController: checkValueRequest.apiController,
        apiHandler: checkValueRequest.apiHandler,
        isAuthorised: checkValueRequest.isAuthorized)
    ;

    try {
      var body = CheckValueResponse.fromJson(callResponse.body);
      return body;
    } catch ( e) {
      debugPrint("api call ${checkValueRequest.apiHandler} triggered an exception ${e.toString()}");
      return CheckValueResponse(success: false, isValueValid: false, timeStamp: "", errors: [CallError(code: "CallTriggeredException", description: e.toString())]);
    }
  }
}