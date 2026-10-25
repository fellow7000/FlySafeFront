import 'package:fs_front/Core/DTO/Club/add_club_request.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';

import '../../../Core/DTO/Club/add_club_response.dart';
import '../../../Core/DTO/Club/change_club_password_request.dart';
import '../../../Core/DTO/Club/change_club_password_response.dart';
import '../../../Core/DTO/Club/change_club_type_request.dart';
import '../../../Core/DTO/Club/change_club_type_response.dart';
import '../../../Core/DTO/Club/delete_club_request.dart';
import '../../../Core/DTO/Club/delete_club_response.dart';
import '../../../Core/DTO/Club/leave_club_request.dart';
import '../../../Core/DTO/Club/leave_club_response.dart';
import '../../../Core/DTO/Club/club_details_response.dart';
import '../../../Core/DTO/Club/join_club_request.dart';
import '../../../Core/DTO/Club/join_club_response.dart';
import '../../../Core/DTO/Club/add_club_member_request.dart';
import '../../../Core/DTO/Club/club_member_change_response.dart';
import '../../../Core/DTO/Club/get_club_members_request.dart';
import '../../../Core/DTO/Club/get_club_members_response.dart';
import '../../../Core/DTO/Club/remove_club_member_request.dart';
import '../../../Core/DTO/Club/set_club_member_role_request.dart';
import '../api_call.dart';

//we need it as an abstract class for mock and real implementations!
abstract class IApiClub extends ApiCall {
  static const String clubController = "api/club";
  static const String getPublicClubsHandler = "getpublicclubs";
  static const String checkClubNameFreeHandler = "checkclubnamefree";
  static const String createClubHandler = "createclub";
  static const String joinClubHandler = "joinclub";
  static const String getClubDetailsHandler = "getclubdetails";
  static const String leaveClubHandler = "leaveclub";
  static const String deleteClubHandler = "deleteclub";
  static const String changeClubPasswordHandler = "changeclubpassword";
  static const String changeClubTypeHandler = "changeclubtype";
  static const String getClubMembersHandler = "getclubmembers";
  static const String addClubMemberHandler = "addclubmember";
  static const String setClubMemberRoleHandler = "setclubmemberrole";
  static const String removeClubMemberHandler = "removeclubmember";

  //get the list of public clubs
  Future<List<String>> getPublicClubs();

  //create a new club and assign the user as its owner
  Future<AddClubResponse> createClub({required AddClubRequest addClubRequest});

  //join a club
  Future<JoinClubResponse> joinClub({required JoinClubRequest joinClubRequest});

  //get club's details
  Future<ClubDetailsResponse> getClubDetails({required ClubDetailsRequest clubDetailsRequest});

  //leave a club
  Future<LeaveClubResponse> leaveClub({required LeaveClubRequest leaveClubRequest});

  //delete a club
  Future<DeleteClubResponse> deleteClub({required DeleteClubRequest deleteClubRequest});

  //change the club password
  Future<ChangeClubPasswordResponse> changeClubPassword({required ChangeClubPasswordRequest changeClubPasswordRequest});

  //change the club type (public / non-listed)
  Future<ChangeClubTypeResponse> changeClubType({required ChangeClubTypeRequest changeClubTypeRequest});

  //members of a club with the actions the current user may perform on each of them
  Future<GetClubMembersResponse> getClubMembers({required GetClubMembersRequest getClubMembersRequest});

  //add an existing user by exact user name or email; the answer does not reveal whether the user exists
  Future<ClubMemberChangeResponse> addClubMember({required AddClubMemberRequest addClubMemberRequest});

  //set the club role of a member
  Future<ClubMemberChangeResponse> setClubMemberRole({required SetClubMemberRoleRequest setClubMemberRoleRequest});

  //remove a member from the club
  Future<ClubMemberChangeResponse> removeClubMember({required RemoveClubMemberRequest removeClubMemberRequest});
}
