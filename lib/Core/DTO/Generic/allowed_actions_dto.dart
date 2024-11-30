class AllowedActionsDTO {
  final List<String> allowedActions;

  AllowedActionsDTO({required this.allowedActions});

  factory AllowedActionsDTO.fromJson(Map<String, dynamic> json) {
    return AllowedActionsDTO(
        allowedActions: List.of(json["AllowedActions"]??[]).map((r) => r.toString().toUpperCase()).toList(),
    );
  }
}

//we use global variable because providers are also global.
List<String> requestedActions = [];