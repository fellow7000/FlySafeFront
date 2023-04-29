class ChangeUserPasswordRequest {
  final String oldUserPassword;
  final String newUserPassword;
  final String newUserPasswordConfirmation;

  ChangeUserPasswordRequest({required this.oldUserPassword, required this.newUserPassword, required this.newUserPasswordConfirmation});

  Map<String, dynamic> toJson() {
    return {
      "OldUserPassword": oldUserPassword,
      "NewUserPassword": newUserPassword,
      "NewUserPasswordConfirmation": newUserPasswordConfirmation,
    };
  }
}