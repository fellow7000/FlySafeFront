class ClubDetailsRequest  {

  final String clubId;

  ClubDetailsRequest({required this.clubId});

  Map<String, dynamic> toJson() {
    return {
      "clubId": clubId,
    };
  }
}