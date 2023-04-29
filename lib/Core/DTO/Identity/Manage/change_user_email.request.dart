class ChangeUserEmailRequest {
  final String newEmail;

  ChangeUserEmailRequest({required this.newEmail});

  Map<String, dynamic> toJson() {
    return {
      "NewEmail": newEmail,
    };
  }
}