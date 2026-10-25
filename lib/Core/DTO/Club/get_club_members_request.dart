class GetClubMembersRequest {
  final String clubId;

  GetClubMembersRequest({required this.clubId});

  Map<String, dynamic> toJson() => {"ClubId": clubId};
}
