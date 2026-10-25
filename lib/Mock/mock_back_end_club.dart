import 'package:fs_front/Core/DTO/Club/add_club_request.dart';

import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';

import '../Core/DTO/Club/change_club_password_request.dart';
import '../Core/DTO/Club/change_club_password_response.dart';
import '../Core/DTO/Club/club_details_response.dart';
import '../Core/DTO/Club/delete_club_request.dart';
import '../Core/DTO/Club/delete_club_response.dart';
import '../Core/DTO/Club/leave_club_request.dart';
import '../Core/DTO/Club/leave_club_response.dart';
import '../Infrastructure/BackEnd/ClubCalls/i_api_club.dart';

class FakeBackEndClub implements IApiClub {
  @override
  Future<List<String>> getPublicClubs() {
    return Future.delayed(const Duration(seconds: 1), () => ["Hohenasperg LSV", "Fellow7000", "Flight Academy", DateTime.now().toString()]);
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

  @override
  Future<ClubDetailsResponse> getClubDetails({required ClubDetailsRequest clubDetailsRequest}) {
    // TODO: implement getClubsDetail
    throw UnimplementedError();
  }

  @override
  Future<LeaveClubResponse> leaveClub({required LeaveClubRequest leaveClubRequest}) {
    throw UnimplementedError();
  }

  @override
  Future<DeleteClubResponse> deleteClub({required DeleteClubRequest deleteClubRequest}) {
    throw UnimplementedError();
  }

  @override
  Future<ChangeClubPasswordResponse> changeClubPassword({required ChangeClubPasswordRequest changeClubPasswordRequest}) {
    throw UnimplementedError();
  }
}
