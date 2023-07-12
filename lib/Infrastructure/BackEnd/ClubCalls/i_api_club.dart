import 'package:fs_front/Core/DTO/Club/add_club_request.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';

import '../../../Core/DTO/Club/add_club_response.dart';
import '../../../Core/DTO/Club/club_details_response.dart';
import '../../../Core/DTO/Club/club_dto.dart';
import '../../../Core/DTO/Club/join_club_request.dart';
import '../../../Core/DTO/Club/join_club_response.dart';
import '../api_call.dart';

//we need it as an abstract class for mock and real implementations!
abstract class IApiClub extends ApiCall {
  static const String clubController = "api/club";
  static const String webSocketController = "api/websocket";
  static const String getPublicClubsHandler = "getpublicclubs";
  static const String checkClubNameFreeHandler = "checkclubnamefree";
  static const String checkClubNameFreeWebSocket = "checkclubnamesocket";
  static const String checkValueSocket = "checkvaluesocket";
  static const String createClubHandler = "createclub";
  static const String joinClubHandler = "joinclub";
  static const String getClubDetailsHandler = "getclubdetails";

  //get the list of public clubs
  Future<List<String>> getPublicClubs();

  //create a new club and assign the user as its owner
  Future<AddClubResponse> createClub({required AddClubRequest addClubRequest});

  //join a club
  Future<JoinClubResponse> joinClub({required JoinClubRequest joinClubRequest});

  //get club's details
  Future<ClubDetailsResponse> getClubDetails({required ClubDetailsRequest clubDetailsRequest});
}