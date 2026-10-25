import '../../Vars/enums.dart';

class ChangeClubTypeRequest {
  final String clubId;
  final ClubType newClubType;

  ChangeClubTypeRequest({required this.clubId, required this.newClubType});

  //the back end enum uses the same numeric values as the ClubType index
  Map<String, dynamic> toJson() {
    return {
      "ClubId": clubId,
      "NewClubType": newClubType.index,
    };
  }
}
