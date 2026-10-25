class DeleteClubRequest {
  final String clubId;
  final String clubNameConfirmation;
  final String userPassword;

  DeleteClubRequest({required this.clubId, required this.clubNameConfirmation, required this.userPassword});

  Map<String, dynamic> toJson() {
    return {
      "ClubId": clubId,
      "ClubNameConfirmation": clubNameConfirmation,
      "UserPassword": userPassword,
    };
  }
}
