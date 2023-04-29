import '../../Entities/Club/club.dart';
import '../../Vars/enums.dart';

class ClubDTO extends Club {

  ClubDTO({required super.clubID, required super.clubType, required super.clubName, required super.clubComment});

  factory ClubDTO.fromJson(Map<String, dynamic> json) {
    return ClubDTO(
      clubID: json["ClubID"],
      clubType: ClubType.values.elementAt(json["ClubType"]),
      clubName: json["ClubName"],
      clubComment: json["ClubComment"],
    );
  }
}