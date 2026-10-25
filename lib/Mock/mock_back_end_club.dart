import 'package:fs_front/Core/DTO/Club/add_club_request.dart';

import 'package:fs_front/Core/DTO/Club/add_club_response.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_request.dart';
import 'package:fs_front/Core/DTO/Club/join_club_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';

import '../Core/DTO/Club/change_club_password_request.dart';
import '../Core/DTO/Club/change_club_password_response.dart';
import '../Core/DTO/Club/change_club_type_request.dart';
import '../Core/DTO/Club/change_club_type_response.dart';
import '../Core/DTO/Club/club_details_response.dart';
import '../Core/DTO/Club/delete_club_request.dart';
import '../Core/DTO/Club/delete_club_response.dart';
import '../Core/DTO/Club/leave_club_request.dart';
import '../Core/DTO/Club/leave_club_response.dart';
import '../Core/DTO/Base/call_error.dart';
import '../Core/DTO/Club/add_club_member_request.dart';
import '../Core/DTO/Club/club_member_change_response.dart';
import '../Core/DTO/Club/club_member_dto.dart';
import '../Core/DTO/Club/get_club_members_request.dart';
import '../Core/DTO/Club/get_club_members_response.dart';
import '../Core/DTO/Club/remove_club_member_request.dart';
import '../Core/DTO/Club/set_club_member_role_request.dart';
import '../Helpers/club_error_helper.dart';
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

  @override
  Future<ChangeClubTypeResponse> changeClubType({required ChangeClubTypeRequest changeClubTypeRequest}) {
    return Future.delayed(
        const Duration(milliseconds: 300),
        () => ChangeClubTypeResponse(
            resultCode: AppResultCode.ok, clubId: changeClubTypeRequest.clubId, newClubType: changeClubTypeRequest.newClubType, errors: const []));
  }

  //In-memory members. The current user is an Owner (not Root): manages Managers and Members, may make others Owners, cannot touch Owners or himself.
  static const List<String> _rank = [ClubMemberDTO.member, ClubMemberDTO.manager, ClubMemberDTO.owner];
  final String mockCurrentUserId = "u1";
  final Map<String, String> mockMemberRoles = {
    "u1": ClubMemberDTO.owner,
    "u2": ClubMemberDTO.owner,
    "u3": ClubMemberDTO.manager,
    "u4": ClubMemberDTO.member,
    "u5": ClubMemberDTO.member,
  };
  final Map<String, String> mockMemberNames = {
    "u1": "smokepilot",
    "u2": "anna.berger",
    "u3": "max.manager",
    "u4": "lonepilot",
    "u5": "katharina.schneider-hohenasperg",
  };

  String get _actorRole => mockMemberRoles[mockCurrentUserId] ?? ClubMemberDTO.member;

  ClubMemberDTO _mockMember(String id) {
    final role = mockMemberRoles[id]!;
    final isCurrent = id == mockCurrentUserId;
    final manageable = !isCurrent && _rank.indexOf(role) < _rank.indexOf(_actorRole);
    final allowed = manageable ? _rank.reversed.where((r) => r != role && _rank.indexOf(r) <= _rank.indexOf(_actorRole)).toList() : <String>[];
    return ClubMemberDTO(userId: id, userName: mockMemberNames[id]!, role: role, isCurrentUser: isCurrent, allowedRoles: allowed, canRemove: manageable);
  }

  @override
  Future<GetClubMembersResponse> getClubMembers({required GetClubMembersRequest getClubMembersRequest}) {
    final ids = mockMemberRoles.keys.toList()
      ..sort((a, b) {
        final byRank = _rank.indexOf(mockMemberRoles[b]!).compareTo(_rank.indexOf(mockMemberRoles[a]!));
        return byRank != 0 ? byRank : mockMemberNames[a]!.compareTo(mockMemberNames[b]!);
      });
    return Future.delayed(
        const Duration(milliseconds: 300),
        () => GetClubMembersResponse(
            resultCode: AppResultCode.ok,
            clubId: getClubMembersRequest.clubId,
            canAddMember: _actorRole != ClubMemberDTO.member,
            members: ids.map(_mockMember).toList(),
            errors: const []));
  }

  @override
  Future<ClubMemberChangeResponse> addClubMember({required AddClubMemberRequest addClubMemberRequest}) {
    final name = addClubMemberRequest.userNameOrEmail.trim();
    if (!mockMemberNames.values.any((n) => n.toLowerCase() == name.toLowerCase())) {
      final id = "u${DateTime.now().microsecondsSinceEpoch}";
      mockMemberRoles[id] = ClubMemberDTO.member;
      mockMemberNames[id] = name.split("@").first;
    }
    return Future.delayed(const Duration(milliseconds: 300),
        () => ClubMemberChangeResponse(resultCode: AppResultCode.ok, clubId: addClubMemberRequest.clubId, errors: const []));
  }

  ClubMemberChangeResponse? _mockRefusal(String clubId, String userId) {
    String? code;
    if (userId == mockCurrentUserId) {
      code = ClubErrorCodes.cannotChangeOwnMembership;
    } else if (!mockMemberRoles.containsKey(userId)) {
      code = ClubErrorCodes.userNotMember;
    } else if (!_mockMember(userId).isManageable) {
      code = ClubErrorCodes.memberRankTooHigh;
    }
    return code == null
        ? null
        : ClubMemberChangeResponse(resultCode: AppResultCode.conflict, clubId: clubId, errors: [CallError(code: code, description: code)]);
  }

  @override
  Future<ClubMemberChangeResponse> setClubMemberRole({required SetClubMemberRoleRequest setClubMemberRoleRequest}) {
    final r = setClubMemberRoleRequest;
    final refusal = _mockRefusal(r.clubId, r.userId);
    if (refusal == null) mockMemberRoles[r.userId] = r.role;
    return Future.delayed(const Duration(milliseconds: 300),
        () => refusal ?? ClubMemberChangeResponse(resultCode: AppResultCode.ok, clubId: r.clubId, userId: r.userId, role: r.role, errors: const []));
  }

  @override
  Future<ClubMemberChangeResponse> removeClubMember({required RemoveClubMemberRequest removeClubMemberRequest}) {
    final r = removeClubMemberRequest;
    final refusal = _mockRefusal(r.clubId, r.userId);
    if (refusal == null) {
      mockMemberRoles.remove(r.userId);
      mockMemberNames.remove(r.userId);
    }
    return Future.delayed(const Duration(milliseconds: 300),
        () => refusal ?? ClubMemberChangeResponse(resultCode: AppResultCode.ok, clubId: r.clubId, userId: r.userId, errors: const []));
  }
}
