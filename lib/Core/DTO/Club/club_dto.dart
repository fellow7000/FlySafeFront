import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';

import '../../Entities/Club/club.dart';
import '../../Vars/enums.dart';
import '../../Vars/providers.dart';

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