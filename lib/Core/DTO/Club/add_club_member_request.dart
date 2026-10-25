class AddClubMemberRequest {
  //Must match the back end limit of addclubmember.
  static const int maxLength = 256;

  final String clubId;
  final String userNameOrEmail;

  AddClubMemberRequest({required this.clubId, required this.userNameOrEmail});

  Map<String, dynamic> toJson() => {"ClubId": clubId, "UserNameOrEmail": userNameOrEmail};
}
