import 'package:fs_front/Core/DTO/Identity/Manage/change_user_email.request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_email_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_response.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:fs_front/Core/DTO/Identity/check_username_free_request.dart';

import 'package:fs_front/Core/DTO/Identity/check_username_free_response.dart';
import 'package:fs_front/Core/DTO/Identity/registration_request.dart';
import 'package:fs_front/Core/DTO/Identity/registration_response.dart';

import '../Core/DTO/Identity/authentification_requrest.dart';
import '../Core/DTO/Identity/authentification_response.dart';
import '../Core/DTO/Identity/reset_user_password_request.dart';
import '../Core/DTO/Identity/reset_user_password_response.dart';
import '../Core/Vars/enums.dart';
import '../Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';

class FakeBackEndIdentity implements IApiIdentity {
  @override
  Future<AuthentificationResponse> signIn({required AuthentificationRequest authentificationRequest}) {
    return Future.delayed(const Duration(seconds: 1), () => AuthentificationResponse(success: true, accessToken: 'accessToken', logAs: LogAs.user, hash: "#%@S", errors: []));
  }

  @override
  Future<ResetUserPasswordResponse> requestUserPasswordReset({required ResetUserPasswordRequest resetUserPasswordRequest}) {
    return Future.delayed(const Duration(seconds: 2), () => ResetUserPasswordResponse(success: true, email: resetUserPasswordRequest.email, errors: []));
  }

  @override
  Future<CheckUserNameFreeResponse> checkUserNameFree({required CheckUserNameFreeRequest checkUserNameFreeRequest}) async {
    // TODO: implement checkUserNameFree
    throw UnimplementedError();
  }

  @override
  Future<RegistrationResponse> signUp({required RegistrationRequest registrationRequest}) async {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResponse> getUserProfile() async {
    // TODO: implement getUserProfile
    throw UnimplementedError();
  }

  @override
  Future<ChangeUserPasswordResponse> changeUserPassword({required ChangeUserPasswordRequest changeUserPasswordRequest}) {
    // TODO: implement changeUserPassword
    throw UnimplementedError();
  }

  @override
  Future<ChangeUserEmailResponse> changeUserEmail({required ChangeUserEmailRequest changeUserEmailRequest}) {
    // TODO: implement changeUserEmail
    throw UnimplementedError();
  }

  @override
  Future<DeleteUserAccountResponse> deleteUserAccount({required DeleteUserAccountRequest deleteUserAccountRequest}) {
    // TODO: implement deleteUserAccount
    throw UnimplementedError();
  }
}