import 'package:fs_front/Core/DTO/Club/add_club_request.dart';

import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';

import '../Core/DTO/Identity/authentification_requrest.dart';
import '../Core/DTO/Identity/authentification_response.dart';
import '../Core/DTO/Identity/reset_user_password_request.dart';
import '../Core/DTO/Identity/reset_user_password_response.dart';
import '../Core/Vars/enums.dart';
import '../Infrastructure/BackEnd/ClubCalls/i_api_club.dart';

class FakeBackEndClub implements IApiClub {
  @override
  Future<List<String>> getPublicClubs() {
    return Future.delayed(const Duration(seconds: 1), () => ["Hohenasperg LSV", "Fellow7000", "Flight Academy", DateTime.now().toString()]);
  }

  @override
  Future<AuthentificationResponse> signIn({required AuthentificationRequest authentificationRequest}) {
    return Future.delayed(const Duration(seconds: 1), () => AuthentificationResponse(success: true, accessToken: 'accessToken', logAs: LogAs.user, hash: "#%@S", errors: []));
  }

  @override
  Future<ResetUserPasswordResponse> resetUserPasswordRequest({required ResetUserPasswordRequest resetUserPasswordRequest}) {
    return Future.delayed(const Duration(seconds: 2), () => ResetUserPasswordResponse(success: true, email: resetUserPasswordRequest.email, errors: []));
  }

  @override
  Future<AddClubResponse> createClub({required AddClubRequest addClubRequest}) {
    // TODO: implement createClub
    throw UnimplementedError();
  }

  @override
  Future<JoinClubResponse> joinClub({required JoinClubRequest joinClubRequest}) {
    // TODO: implement joinClub
    throw UnimplementedError();
  }
}