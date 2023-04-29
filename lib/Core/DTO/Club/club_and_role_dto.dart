import '../../Entities/Club/club.dart';
import '../../Vars/enums.dart';

class ClubAndRoleDTO extends Club {

  //final List<String> roleIds;
  //final List<List<String>> roleIdAndNames;
  List<Tuple<String, String>> roles;

  ClubAndRoleDTO({required super.clubID, required super.clubType, required super.clubName, required super.clubComment, required this.roles});

  factory ClubAndRoleDTO.fromJson(Map<String, dynamic> json) {

    final rolesList= List<Tuple<String, String>>.from(
        json['Roles'].map((roleJson) => Tuple<String, String>(
            roleJson['Item1'], roleJson['Item2'])));

    return ClubAndRoleDTO(
      clubID: json["ClubID"],
      clubType: ClubType.values.elementAt(json["ClubType"]),
      clubName: json["ClubName"],
      clubComment: json["ClubComment"],
      //roleIds: List.of(json["RoleIds"]??[]).map((r) => r.toString()).toList(),
      roles: rolesList
    );
  }
}

class Tuple<A, B> {
  final A item1;
  final B item2;

  const Tuple(this.item1, this.item2);
}

// void main() {
//   String jsonString = '[["John", "Doe"], ["Jane", "Smith"], ["Bob", "Jones"]]';
//   List<List<String>> tupleList = List<List<String>>.from(json.decode(jsonString)
//       .map((tuple) => List<String>.from(tuple.map((name) => name.toString()))));
//
//   for (var tuple in tupleList) {
//     print('${tuple[0]} ${tuple[1]}');
//   }
// }
//
//   class A {
//     final List<List<String>> roleIdAndNames;
//     A({required this.roleIdAndNames});
//   }