import '../../Vars/enums.dart';

class ResetUserPasswordRequest {
  final String locale; //do not need to encode locale in json as it's handled in API headers
  final String email;
  final EndDevice endDevice;

  const ResetUserPasswordRequest({required this.locale, required this.email, required this.endDevice});

  Map<String, dynamic> toJson() {
    return {
      "Email": email,
      "EndDevice": endDevice.index,
    };
  }
}