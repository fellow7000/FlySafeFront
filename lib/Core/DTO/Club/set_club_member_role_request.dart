class SetClubMemberRoleRequest {
  final String clubId;
  final String userId;
  final String role; //Club_Owner, Club_Manager or Club_Member

  SetClubMemberRoleRequest({required this.clubId, required this.userId, required this.role});

  Map<String, dynamic> toJson() => {"ClubId": clubId, "UserId": userId, "Role": role};
}
