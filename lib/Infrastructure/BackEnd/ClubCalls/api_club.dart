import 'package:fs_front/Core/DTO/Base/call_response.dart';
import 'package:fs_front/Core/DTO/Club/add_club_request.dart';
import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:fs_front/Core/DTO/Club/get_clubs_response.dart';

import '../../../Core/DTO/Club/change_club_password_request.dart';
import '../../../Core/DTO/Club/change_club_password_response.dart';
import '../../../Core/DTO/Club/change_club_type_request.dart';
import '../../../Core/DTO/Club/change_club_type_response.dart';
import '../../../Core/DTO/Club/club_details_response.dart';
import '../../../Core/DTO/Club/delete_club_request.dart';
import '../../../Core/DTO/Club/delete_club_response.dart';
import '../../../Core/DTO/Club/leave_club_request.dart';
import '../../../Core/DTO/Club/leave_club_response.dart';
import '../../../Core/DTO/Club/add_club_member_request.dart';
import '../../../Core/DTO/Club/club_member_change_response.dart';
import '../../../Core/DTO/Club/get_club_members_request.dart';
import '../../../Core/DTO/Club/get_club_members_response.dart';
import '../../../Core/DTO/Club/remove_club_member_request.dart';
import '../../../Core/DTO/Club/set_club_member_role_request.dart';
import '../../../Core/Vars/exceptions.dart';
import '../../../Helpers/club_error_helper.dart';
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
      return AddClubResponse(resultCode: AppResultCode.conflict, clubID: "", errors: callResponse.callError!);
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
      return JoinClubResponse(resultCode: AppResultCode.conflict, errors: callResponse.callError!);
    }
  }

  //get the details of a club
  @override
  Future<ClubDetailsResponse> getClubDetails({required ClubDetailsRequest clubDetailsRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.getClubDetailsHandler, body: clubDetailsRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.forbiddenCode) {
      throw Forbidden();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        var body = ClubDetailsResponse.fromJson(callResponse.body);
        return body;
      } catch (e) {
        debugPrint("api call ${IApiClub.getClubDetailsHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      throw Exception("API call finished with code ${callResponse.statusCode}");
      //2023-07-13
      //return ClubDetailsResponse(resultCode: AppResultCode.conflict, errors: callResponse.callError!, club: null);
    }
  }

  //leave a club
  @override
  Future<LeaveClubResponse> leaveClub({required LeaveClubRequest leaveClubRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.leaveClubHandler, body: leaveClubRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.forbiddenCode) {
      throw Forbidden();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        return LeaveClubResponse.fromJson(callResponse.body);
      } catch (e) {
        debugPrint("api call ${IApiClub.leaveClubHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      throw Exception("API call finished with code ${callResponse.statusCode}");
    }
  }

  //delete a club
  @override
  Future<DeleteClubResponse> deleteClub({required DeleteClubRequest deleteClubRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.deleteClubHandler, body: deleteClubRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.forbiddenCode) {
      throw Forbidden();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        return DeleteClubResponse.fromJson(callResponse.body);
      } catch (e) {
        debugPrint("api call ${IApiClub.deleteClubHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      throw Exception("API call finished with code ${callResponse.statusCode}");
    }
  }

  //change the club password
  @override
  Future<ChangeClubPasswordResponse> changeClubPassword({required ChangeClubPasswordRequest changeClubPasswordRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.changeClubPasswordHandler, body: changeClubPasswordRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.forbiddenCode) {
      throw Forbidden();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        return ChangeClubPasswordResponse.fromJson(callResponse.body);
      } catch (e) {
        debugPrint("api call ${IApiClub.changeClubPasswordHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      throw Exception("API call finished with code ${callResponse.statusCode}");
    }
  }

  //change the club type (public / non-listed)
  @override
  Future<ChangeClubTypeResponse> changeClubType({required ChangeClubTypeRequest changeClubTypeRequest}) async {
    CallResponse callResponse = await BackEndCall(webHostUri: webHostUri)
        .callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: IApiClub.changeClubTypeHandler, body: changeClubTypeRequest, isAuthorised: true);

    if (callResponse.statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (callResponse.statusCode == BackEndCall.forbiddenCode) {
      throw Forbidden();
    } else if (callResponse.statusCode == BackEndCall.okCode || callResponse.statusCode == BackEndCall.conflictCode) {
      try {
        return ChangeClubTypeResponse.fromJson(callResponse.body);
      } catch (e) {
        debugPrint("api call ${IApiClub.changeClubTypeHandler} triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else {
      throw Exception("API call finished with code ${callResponse.statusCode}");
    }
  }

  @override
  Future<GetClubMembersResponse> getClubMembers({required GetClubMembersRequest getClubMembersRequest}) =>
      _memberCall(IApiClub.getClubMembersHandler, getClubMembersRequest, (json, code) => GetClubMembersResponse.fromJson(json, statusCode: code));

  @override
  Future<ClubMemberChangeResponse> addClubMember({required AddClubMemberRequest addClubMemberRequest}) =>
      _memberCall(IApiClub.addClubMemberHandler, addClubMemberRequest, (json, code) => ClubMemberChangeResponse.fromJson(json, statusCode: code));

  @override
  Future<ClubMemberChangeResponse> setClubMemberRole({required SetClubMemberRoleRequest setClubMemberRoleRequest}) =>
      _memberCall(IApiClub.setClubMemberRoleHandler, setClubMemberRoleRequest, (json, code) => ClubMemberChangeResponse.fromJson(json, statusCode: code));

  @override
  Future<ClubMemberChangeResponse> removeClubMember({required RemoveClubMemberRequest removeClubMemberRequest}) =>
      _memberCall(IApiClub.removeClubMemberHandler, removeClubMemberRequest, (json, code) => ClubMemberChangeResponse.fromJson(json, statusCode: code));

  //Member calls: 200 and 409 carry a body; 400, 403, 404 and 429 are turned into a response with one error code the UI translates.
  //A 400 of addclubmember means an empty or too long name; for the other calls it is a rejected request.
  static const Map<int, String> _memberStatusErrors = {
    BackEndCall.badRequest400Code: ClubErrorCodes.memberRequestInvalid,
    BackEndCall.forbiddenCode: ClubErrorCodes.actionNotAllowed,
    404: ClubErrorCodes.clubNotFound,
    BackEndCall.tooManyRequestsCode: ClubErrorCodes.tooManyAttempts,
  };

  Future<T> _memberCall<T>(String handler, dynamic body, T Function(Map<String, dynamic> json, int statusCode) fromJson) async {
    CallResponse callResponse =
        await BackEndCall(webHostUri: webHostUri).callAPI(callTypeAPI: CallTypeAPI.post, apiController: IApiClub.clubController, apiHandler: handler, body: body, isAuthorised: true);
    final statusCode = callResponse.statusCode;

    if (statusCode == BackEndCall.unauthorizedCode) {
      throw Unauthorised();
    } else if (statusCode == BackEndCall.okCode || statusCode == BackEndCall.conflictCode) {
      try {
        return fromJson(Map<String, dynamic>.from(callResponse.body), statusCode);
      } catch (e) {
        debugPrint("api call $handler triggered an exception during body encoding ${e.toString()}");
        throw Exception("exception during body encoding ${e.toString()}");
      }
    } else if (_memberStatusErrors.containsKey(statusCode)) {
      final code = statusCode == BackEndCall.badRequest400Code && handler == IApiClub.addClubMemberHandler
          ? ClubErrorCodes.memberInputInvalid
          : _memberStatusErrors[statusCode];
      return fromJson({
        "Errors": [
          {"Code": code, "Description": "HTTP $statusCode"}
        ]
      }, statusCode);
    } else {
      throw Exception("API call finished with code $statusCode");
    }
  }
}
