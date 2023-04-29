class CheckUserNameFreeRequest{
  final String userName;

  const CheckUserNameFreeRequest({required this.userName});

  Map<String, dynamic> toJson() {
    return {
      "UserName": userName
    };
  }
}