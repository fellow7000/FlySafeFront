class LeaveClubRequest {
  final String clubId;

  LeaveClubRequest({required this.clubId});

  Map<String, dynamic> toJson() {
    return {"ClubId": clubId};
  }
}
