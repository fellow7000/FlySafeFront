import 'dart:typed_data';

import '../../Vars/enums.dart';

class AddClubRequest {
  final String clubName;
  final String clubPassword;
  final Uint8List? clubPic;
  final Uint8List? clubPicThmb;
  final String clubComment;
  final ClubType clubType;
  final ClubCreateMode clubCreateMode;
  final EndDevice endDevice;

  AddClubRequest({
    required this.clubName,
    required this.clubPassword,
    this.clubPic,
    this.clubPicThmb,
    this.clubComment = "",
    required this.clubType,
    this.clubCreateMode = ClubCreateMode.createAndAssign,
    required this.endDevice,});

  Map<String, dynamic> toJson() {
    return {
      "ClubName": clubName,
      "ClubPassword": clubPassword,
      "ClubPic": clubPic,
      "ClubPicThmb": clubPicThmb,
      "ClubComment": clubComment,
      "ClubType": clubType.index,
      "ClubCreateMode": clubCreateMode.index,
      "EndDevice": endDevice.index,
    };
  }
}