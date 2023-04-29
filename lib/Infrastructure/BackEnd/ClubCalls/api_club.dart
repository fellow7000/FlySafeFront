import 'package:fs_front/Core/DTO/Base/call_response.dart';
import 'package:fs_front/Core/DTO/Club/add_club_request.dart';
import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:fs_front/Core/DTO/Club/get_clubs_response.dart';

import '../../../Core/Vars/exceptions.dart';
import 'i_api_club.dart';
import '../backend_call.dart';
import '../../../Core/DTO/Club/club_dto.dart';

class ApiClub implements IApiClub {
  final Uri webHostUri;

  ApiClub({required this.webHostUri});

  //get the list of public clubs
  @override
  Future<List<String>> getPublicClubs() async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri).callAPI(callTypeAPI: CallTypeAPI.get, apiController: IApiClub.clubController, apiHandler: IApiClub.getPublicClubsHandler);

      if (callResponse.statusCode == BackEndCall.okCode) {
        try {
        var body = GetClubsResponse.fromJson(callResponse.body);
        List<String> clubList = [];
        for (ClubDTO clubDTO in body.clubList) {
          clubList.add(clubDTO.clubName);
        }
        return clubList;
        } catch (e) {
          debugPrint("exception during body encoding ${e.toString()}");
          throw Exception("exception during body encoding ${e.toString()}");
        }
      } else {
        debugPrint("api call failed");
        throw Exception(callResponse.body);
      }
  }

  //add a new club
  @override
  Future<AddClubResponse> createClub({required AddClubRequest addClubRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.createClubHandler, body: addClubRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.okCode) {
      try {
        var body = AddClubResponse.fromJson(callResponse.body);
        return body;
      } catch (e) {
        debugPrint("api call ${IApiClub.createClubHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      return AddClubResponse(success: false, clubID: "", errors: callResponse.callError!);
    }
  }

  //let a user join a club
  @override
  Future<JoinClubResponse> joinClub({required JoinClubRequest joinClubRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.joinClubHandler, body: joinClubRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        var body = JoinClubResponse.fromJson(callResponse.body);
        return body;
      } catch (e) {
        debugPrint("api call ${IApiClub.joinClubHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      return JoinClubResponse(success: false, errors: callResponse.callError!);
    }
  }



}