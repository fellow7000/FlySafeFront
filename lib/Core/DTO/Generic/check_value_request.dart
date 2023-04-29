class CheckValueRequest<T>{
  final String value;
  final String timeStamp;
  final String apiController;
  final String apiHandler;
  final bool isAuthorized;

  const CheckValueRequest({required this.value, required this.timeStamp, required this.apiController, required this.apiHandler, required this.isAuthorized});

  Map<String, dynamic> toJson() {
    return {
      "Value" : value,
      "TimeStamp" : timeStamp
    };
  }
}