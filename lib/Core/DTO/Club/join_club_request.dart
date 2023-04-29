import 'package:fs_front/Core/Vars/enums.dart';

class JoinClubRequest {
  final String clubName;
  final String clubPassword;
  final PasswordType passwordType;
  final EndDevice endDevice;

  JoinClubRequest({
    required this.clubName,
    required this.clubPassword,
    required this.passwordType,
    required this.endDevice,});

  Map<String, dynamic> toJson() {
    return {
      "ClubName": clubName,
      "ClubPassword": clubPassword,
      "PasswordType" : passwordType.index,
      "EndDevice": endDevice.index,
    };
  }
}