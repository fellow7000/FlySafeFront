import '../../Vars/enums.dart';

class AuthentificationRequest{
  final String userNameOrEmail;
  final String password;
  final PasswordType passwordType;
  final LogAs logAs;
  final bool returnPasswordHash;
  final EndDevice endDevice;
  final bool keepSignedIn;

  const AuthentificationRequest(
       {required this.userNameOrEmail,
         required this.password,
         required this.passwordType,
         required this.logAs,
         required this.returnPasswordHash,
         required this.endDevice,
         required this.keepSignedIn});

  Map<String, dynamic> toJson() {
    return {
      "UserNameOrEmail": userNameOrEmail,
      "Password": password,
      "PasswordType": passwordType.index,
      "LogAs": logAs.index,
      "ReturnPasswordHash" : returnPasswordHash,
      "EndDevice": endDevice.index,
      "KeepSignedIn": keepSignedIn,
    };
  }
}