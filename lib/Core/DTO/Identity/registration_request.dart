import 'dart:typed_data';

import '../../Vars/enums.dart';

class RegistrationRequest {
  final String userName;
  final String email;
  final String userPassword;
  final Uint8List? userPic;
  final Uint8List? userPicThmb;
  final String clubName;
  final String clubPassword;
  final Uint8List? clubPic;
  final Uint8List? clubPicThmb;
  final String clubComment;
  final ClubType clubType;
  final EndDevice endDevice;
  final bool keepSignedIn;

  RegistrationRequest({required this.userName,
  required this.email,
  required this.userPassword,
  this.userPic,
  required this.clubName,
  required this.clubPassword,
  this.clubPic,
  this.clubPicThmb,
  this.userPicThmb,
  this.clubComment = "",
  required this.clubType,
  required this.endDevice,
  this.keepSignedIn = true});

  Map<String, dynamic> toJson() {
    return {
      "UserName": userName,
      "Email": email,
      "UserPassword": userPassword,
      "UserPic": userPic,
      "UserPicThmb": userPicThmb,
      "ClubName": clubName,
      "ClubPassword": clubPassword,
      "ClubPic": clubPic,
      "ClubPicThmb": clubPicThmb,
      "ClubComment": clubComment,
      "ClubType": clubType.index,
      "EndDevice": endDevice.index,
      "KeepSignedIn": keepSignedIn,
    };
  }
}