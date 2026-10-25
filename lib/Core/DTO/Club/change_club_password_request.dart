class ChangeClubPasswordRequest {
  final String clubId;
  final String oldClubPassword;
  final String newClubPassword;

  ChangeClubPasswordRequest({required this.clubId, required this.oldClubPassword, required this.newClubPassword});

  Map<String, dynamic> toJson() {
    return {
      "ClubId": clubId,
      "OldClubPassword": oldClubPassword,
      "NewClubPassword": newClubPassword,
    };
  }
}
