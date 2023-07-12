import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_email.request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_email_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/get_clubs_roles_actions.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_requrest.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_response.dart';
import 'package:fs_front/Core/DTO/Identity/check_username_free_request.dart';
import 'package:fs_front/Core/DTO/Identity/check_username_free_response.dart';
import 'package:fs_front/Core/DTO/Identity/registration_request.dart';
import 'package:fs_front/Core/DTO/Identity/registration_response.dart';
import 'package:fs_front/Core/DTO/Identity/reset_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/reset_user_password_response.dart';
import 'package:fs_front/Core/Vars/exceptions.dart';
import 'package:fs_front/Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/DTO/Base/call_response.dart';
import '../../../Core/Vars/enums.dart';
import '../../../Helpers/app_helper.dart';
import 'package:http/http.dart' as http;

import '../api_call.dart';
import '../backend_call.dart';

class ApiIdentity implements IApiIdentity {
  final Uri webHostUri;

  ApiIdentity({required this.webHostUri});

  @override
  Future<RegistrationResponse> signUp({required RegistrationRequest registrationRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, body: registrationRequest, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.registerHandler);

    try {
      var body = RegistrationResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call registration of a new user triggered an exception ${e.toString()}");
      return RegistrationResponse(
          resultCode: AppResultCode.conflict,
          userName: "",
          accessToken: "",
          userPasswordHash: "",
          clubName: "",
          logAs: LogAs.failed,
          errors: [CallError(code: "CallTriggeredException", description: e.toString())]);
    }
  }

  @override
  Future<AuthentificationResponse> signIn({required AuthentificationRequest authentificationRequest}) async {
    Uri uri = AppHelper.generateUri(host: webHostUri, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.loginHandler);

    try {
      var body = jsonEncode(authentificationRequest);

      var response = await http.post(uri, headers: BackEndCall.basisHeaders, body: body).timeout(BackEndCall.callTimeOut);
      if (response.statusCode == BackEndCall.okCode) {
        return AuthentificationResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == BackEndCall.unauthorizedCode) {
        return AuthentificationResponse(resultCode: AppResultCode.conflict, accessToken: "", logAs: LogAs.none, hash: "", errors: [BackEndCall.unauthorizationError]);
      } else {
        debugPrint("api call login failed with status code ${response.statusCode}");
        String callErrors = json.decode(response.body)["errors"].toString();
        return AuthentificationResponse(resultCode: AppResultCode.conflict, accessToken: "", logAs: LogAs.none, hash: "", errors: [CallError(code: ApiCall.apiCallError, description: callErrors)]);
      }
    } catch (e) {
      debugPrint("api call login triggered an exception ${e.toString()}");
      throw Exception(); //TODO: need to analyze based on exception
    }
  }

  @override
  Future<ResetUserPasswordResponse> requestUserPasswordReset({required ResetUserPasswordRequest resetUserPasswordRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri).callAPI(
        locale: resetUserPasswordRequest.locale,
        callTypeAPI: CallTypeAPI.post,
        body: resetUserPasswordRequest,
        apiController: IApiIdentity.identityController,
        apiHandler: IApiIdentity.requestPasswordResetHandler);

    try {
      var body = ResetUserPasswordResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call request user password reset triggered an exception ${e.toString()}");
      return ResetUserPasswordResponse(resultCode: AppResultCode.conflict, email: "", errors: [CallError(code: "CallTriggeredException", description: e.toString())]);
    }
  }

  @override
  Future<CheckUserNameFreeResponse> checkUserNameFree({required CheckUserNameFreeRequest checkUserNameFreeRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, body: checkUserNameFreeRequest, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.checkUserNameFreeHandler);

    try {
      var body = CheckUserNameFreeResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.checkUserNameFreeHandler} triggered an exception ${e.toString()}");
      return CheckUserNameFreeResponse(resultCode: AppResultCode.conflict, userNameIsFree: false, errors: [CallError(code: "CallTriggeredException", description: e.toString())]);
    }
  }

  @override
  Future<UserProfileResponse> getUserProfile() async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.get, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.getUserProfileHandler, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    }

    try {
      var body = UserProfileResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.getUserProfileHandler} triggered an exception ${e.toString()}");
      throw Exception("exception during body encoding ${e.toString()}");
    }
  }

  @override
  Future<GetClubsRolesActionsResponse> getClubsRolesActions() async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.get, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.getClubsRolesActionsHandler, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    }

    try {
      var body = GetClubsRolesActionsResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.getClubsRolesActionsHandler} triggered an exception ${e.toString()}");
      throw Exception("exception during body encoding ${e.toString()}");
    }
  }

  @override
  Future<ChangeUserPasswordResponse> changeUserPassword({required ChangeUserPasswordRequest changeUserPasswordRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.changeUserPasswordHandler, body: changeUserPasswordRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    }

    try {
      var body = ChangeUserPasswordResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.changeUserPasswordHandler} triggered an exception ${e.toString()}");
      throw Exception("exception during body encoding ${e.toString()}");
    }
  }

  @override
  Future<ChangeUserEmailResponse> changeUserEmail({required ChangeUserEmailRequest changeUserEmailRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.changeUserEmailHandler, body: changeUserEmailRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    }

    try {
      var body = ChangeUserEmailResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.changeUserEmailHandler} triggered an exception ${e.toString()}");
      throw Exception("exception during body encoding ${e.toString()}");
    }
  }

  @override
  Future<DeleteUserAccountResponse> deleteUserAccount({required DeleteUserAccountRequest deleteUserAccountRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.get, apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.deleteUserAccountHandler, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    }

    try {
      var body = DeleteUserAccountResponse.fromJson(callResponse.body);
      return body;
    } catch (e) {
      debugPrint("api call ${IApiIdentity.deleteUserAccountHandler} triggered an exception ${e.toString()}");
      throw Exception("exception during body encoding ${e.toString()}");
    }
  }
}
