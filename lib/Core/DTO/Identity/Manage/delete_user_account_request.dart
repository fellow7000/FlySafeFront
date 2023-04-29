class DeleteUserAccountRequest {
  final String userName;

  DeleteUserAccountRequest({required this.userName});

  Map<String, dynamic> toJson() {
    return {
      "UserName": DeleteUserAccountRequest
    };
  }
}