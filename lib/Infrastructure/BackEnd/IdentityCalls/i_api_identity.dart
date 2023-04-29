import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_response.dart';
import 'package:fs_front/Core/DTO/Identity/check_username_free_request.dart';
import 'package:fs_front/Core/DTO/Identity/check_username_free_response.dart';
import 'package:fs_front/Core/DTO/Identity/registration_request.dart';

import '../../../Core/DTO/Identity/Manage/change_user_email.request.dart';
import '../../../Core/DTO/Identity/Manage/change_user_email_response.dart';
import '../../../Core/DTO/Identity/Manage/change_user_password_response.dart';
import '../../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../../Core/DTO/Identity/authentification_requrest.dart';
import '../../../Core/DTO/Identity/authentification_response.dart';
import '../../../Core/DTO/Identity/registration_response.dart';
import '../../../Core/DTO/Identity/reset_user_password_request.dart';
import '../../../Core/DTO/Identity/reset_user_password_response.dart';
import '../api_call.dart';

//we need it as an abstract class for mock and real implementations!
abstract class IApiIdentity extends ApiCall {
  static const String identityController = "api/user";
  static const String registerHandler = "register";
  static const String loginHandler = "login";
  static const String requestPasswordResetHandler = "requestuserpasswordreset";
  static const String checkUserNameFreeHandler = "checkusernamefree";
  static const String checkEmailFreeFreeHandler = "checkemailfree";
  static const String getUserProfileHandler = "getuserprofile";
  static const String changeUserPasswordHandler = "changeuserpassword";
  static const String changeUserEmailHandler = "changeuseremail";
  static const String deleteUserAccountHandler = "deleteuserprofile";

  //User or Club Sign-in
  Future<RegistrationResponse> signUp({required RegistrationRequest registrationRequest});

  Future<AuthentificationResponse> signIn({required AuthentificationRequest authentificationRequest});

  Future<CheckUserNameFreeResponse> checkUserNameFree({required CheckUserNameFreeRequest checkUserNameFreeRequest});

  //request an email with user password reset token
  Future<ResetUserPasswordResponse> requestUserPasswordReset({required ResetUserPasswordRequest resetUserPasswordRequest});

  Future<UserProfileResponse> getUserProfile();

  Future<ChangeUserPasswordResponse> changeUserPassword({required ChangeUserPasswordRequest changeUserPasswordRequest});

  Future<ChangeUserEmailResponse> changeUserEmail({required ChangeUserEmailRequest changeUserEmailRequest});

  Future<DeleteUserAccountResponse> deleteUserAccount({required DeleteUserAccountRequest deleteUserAccountRequest});
}