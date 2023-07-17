class ClubDetailsRequest  {

  final String clubId;
  final List<String> requestedActions;

  ClubDetailsRequest({required this.clubId, required this.requestedActions});

  Map<String, dynamic> toJson() {
    return {
      "ClubId": clubId,
      "RequestedActions" : requestedActions
    };
  }
}