import 'package:fs_front/Core/DTO/Club/add_club_request.dart';

import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';

import '../Core/DTO/Club/club_details_response.dart';
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
}