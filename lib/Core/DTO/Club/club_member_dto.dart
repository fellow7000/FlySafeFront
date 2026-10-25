//One member of a club as returned by getclubmembers. The server already applies the rank rules:
//allowedRoles are the roles the current user may assign (the current role excluded), canRemove tells if the current user may remove the member.
class ClubMemberDTO {
  static const String owner = "Club_Owner";
  static const String manager = "Club_Manager";
  static const String member = "Club_Member";

  final String userId;
  final String userName;
  final String role;
  final bool isCurrentUser;
  final List<String> allowedRoles;
  final bool canRemove;

  const ClubMemberDTO(
      {required this.userId, required this.userName, required this.role, this.isCurrentUser = false, this.allowedRoles = const [], this.canRemove = false});

  bool get isManageable => allowedRoles.isNotEmpty || canRemove;

  factory ClubMemberDTO.fromJson(Map<String, dynamic> json) {
    return ClubMemberDTO(
      userId: json["UserId"]?.toString() ?? "",
      userName: json["UserName"]?.toString() ?? "",
      role: json["Role"]?.toString() ?? "",
      isCurrentUser: json["IsCurrentUser"] == true,
      allowedRoles: List.of(json["AllowedRoles"] ?? []).map((r) => r.toString()).toList(),
      canRemove: json["CanRemove"] == true,
    );
  }
}
