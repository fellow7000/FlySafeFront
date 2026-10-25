class RemoveClubMemberRequest {
  final String clubId;
  final String userId;

  RemoveClubMemberRequest({required this.clubId, required this.userId});

  Map<String, dynamic> toJson() => {"ClubId": clubId, "UserId": userId};
}
