import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:fs_front/Core/DTO/Base/call_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:http/http.dart' as http;

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/Vars/globals.dart';
import '../../Helpers/app_helper.dart';

class BackEndCall<T> {
  final Uri webHostUri;
  static const apiVer = "4.0";
  static const String apiVersionHeader = 'x-version';
  static const String localeHeader = "Accept-Language";
  static const String tokenHeader = "Authorization";

  static const callTimeOut = Duration(seconds: 60);

  static const Map<String, String> basisHeaders = {
    //"Access-Control-Allow-Origin": "*",
    //"Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    //"Content-Type": "text/plain",
    "Content-Type": "application/json",
    apiVersionHeader : apiVer
  };

  //REST API return codes
  static const int okCode = 200;
  static const int badRequest400Code = 400;
  static const int unauthorizedCode = 401;
  static const int conflictCode = 409;
  static const int callExceptionCode = -1;
  static const CallError callError = CallError(code: "CallTriggeredError", description: "Call triggered a Backend Error", localError: true);
  static const CallError callExceptionError = CallError(code: "CallTriggeredException", description: "Call triggered an Exception", localError: true);
  static const CallError unauthorizationError = CallError(code: "AuthorizationFailed", description: "Wrong user credentials", localError: true);
  static const CallError badRequestError = CallError(code: "BadRequest", description: "400: Bad Request", localError: true);

  BackEndCall({required this.webHostUri});

  Future<CallResponse> callAPI({required CallTypeAPI callTypeAPI, String? locale, T? body, required String apiController, required apiHandler, bool isAuthorised = false}) async {
    Map<String, String> headers = {};
    headers.addEntries(basisHeaders.entries);

    if (locale != null) {
      headers.addEntries({localeHeader:locale}.entries);
    } else {
      headers.addEntries({localeHeader:globalContext.locale.toString().replaceAll("_", "-")}.entries);
    }

    if (isAuthorised) {
      headers.addEntries({tokenHeader:"Bearer $accessToken"}.entries);
    }

    Uri uri = AppHelper.generateUri(host: webHostUri, apiController: apiController, apiHandler: apiHandler);

    try {
      http.Response response;

      switch (callTypeAPI) {
        case CallTypeAPI.get:
          response = await http.get(uri, headers: headers).timeout(BackEndCall.callTimeOut);
          break;
        case CallTypeAPI.post:
          dynamic payloadTemp = body;
          dynamic payload;
          if (payloadTemp is List<String>) {
            payload = jsonEncode(body);
            //debugPrint(jsonEncode(payload));
          } else {
            payload = jsonEncode(payloadTemp.toJson());
            //debugPrint(jsonEncode(payload.toJson()));
          }
          debugPrint(payload);
          response = await http.post(uri, headers: headers, body: payload).timeout(BackEndCall.callTimeOut);
          break;
        default:
          throw UnimplementedError("Wrong API Type call");
      }

      if (response.statusCode == BackEndCall.okCode) {
        debugPrint("api call success $uri");
        return CallResponse(success: true, statusCode: BackEndCall.okCode, body: json.decode(response.body), callError: []);
      } else if (response.statusCode == BackEndCall.badRequest400Code) {
        debugPrint("400 Bad Request for api call $uri");
        return CallResponse(success: false, statusCode: response.statusCode, callError: [badRequestError]);
      } else if (response.statusCode == BackEndCall.unauthorizedCode) {
        debugPrint("401 Authorization error during api call $uri");
        return CallResponse(success: false, statusCode: response.statusCode, callError: [unauthorizationError]);
      } else if (response.statusCode == BackEndCall.conflictCode) {
        debugPrint("409 api call was processed but returned negative results $uri");
        return CallResponse(success: false, statusCode: response.statusCode, body: json.decode(response.body), callError: []);
      } else {
        debugPrint("api call $uri failed with error: ${utf8.decode(response.bodyBytes)}");
        return CallResponse(success: false, statusCode: response.statusCode, callError: [CallError(code: callError.code, description: utf8.decode(response.bodyBytes))]);
      }
    } catch (e) {
      debugPrint("api call $uri triggered exception ${e.toString()}");
      return CallResponse(success: false, statusCode: BackEndCall.callExceptionCode, callError:  [CallError(code: callExceptionError.code, description: e.toString(), localError: true)]);
    }
  }
}
