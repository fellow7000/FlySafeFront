import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/DTO/Club/change_club_type_request.dart';
import 'package:fs_front/Core/DTO/Club/change_club_type_response.dart';
import 'package:fs_front/Core/DTO/Club/club_and_role_dto.dart';
import 'package:fs_front/Core/DTO/Club/club_details_request.dart';
import 'package:fs_front/Core/DTO/Club/club_details_response.dart';
import 'package:fs_front/Core/DTO/Club/club_dto.dart';
import 'package:fs_front/Core/DTO/Generic/allowed_actions_dto.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/get_clubs_roles_actions.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Mock/mock_back_end_club.dart';
import 'package:fs_front/Core/DTO/Base/call_error.dart';
import 'package:fs_front/Core/DTO/Club/add_club_member_request.dart';
import 'package:fs_front/Core/DTO/Club/club_member_change_response.dart';
import 'package:fs_front/Core/DTO/Club/club_member_dto.dart';
import 'package:fs_front/Core/DTO/Club/get_club_members_request.dart';
import 'package:fs_front/Core/DTO/Club/get_club_members_response.dart';
import 'package:fs_front/Core/DTO/Club/remove_club_member_request.dart';
import 'package:fs_front/Core/DTO/Club/set_club_member_role_request.dart';
import 'package:fs_front/UI/Clubs/club_details.dart';
import 'package:fs_front/UI/Clubs/club_members.dart';
import 'package:fs_front/UI/Clubs/delete_club.dart';
import 'package:fs_front/UI/Themes/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EnLoader extends AssetLoader {
  const _EnLoader(this.translations);
  final Map<String, dynamic> translations;
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => translations;
}

class _FakeClubBackEnd extends FakeBackEndClub {
  _FakeClubBackEnd(this.type, this.actions);

  ClubType type;
  final List<String> actions;
  int detailsCalls = 0;
  ChangeClubTypeRequest? lastChange;

  @override
  Future<ClubDetailsResponse> getClubDetails({required ClubDetailsRequest clubDetailsRequest}) async {
    detailsCalls++;
    return ClubDetailsResponse(
      resultCode: AppResultCode.ok,
      club: ClubDTO(clubID: "c1", clubType: type, clubName: "Test Club", clubComment: ""),
      allowedActions: AllowedActionsDTO(allowedActions: actions.map((a) => a.toUpperCase()).toList()),
      errors: const [],
    );
  }

  @override
  Future<ChangeClubTypeResponse> changeClubType({required ChangeClubTypeRequest changeClubTypeRequest}) async {
    lastChange = changeClubTypeRequest;
    final previous = type;
    type = changeClubTypeRequest.newClubType;
    return ChangeClubTypeResponse(resultCode: AppResultCode.ok, clubId: "c1", previousClubType: previous, newClubType: type, errors: const []);
  }

  String? refuseRoleChangeWith;

  @override
  Future<ClubMemberChangeResponse> setClubMemberRole({required SetClubMemberRoleRequest setClubMemberRoleRequest}) {
    if (refuseRoleChangeWith == null) return super.setClubMemberRole(setClubMemberRoleRequest: setClubMemberRoleRequest);
    return Future.value(ClubMemberChangeResponse(
        resultCode: AppResultCode.conflict, errors: [CallError(code: refuseRoleChangeWith!, description: "server text")]));
  }
}

late Map<String, dynamic> _en;

Future<void> _pump(WidgetTester tester, Widget home, {List overrides = const []}) async {
  winWidth = WindowWidth.large;
  windowWidth = 400;
  tester.view.physicalSize = const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: langPath,
    startLocale: const Locale('en'),
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    assetLoader: _EnLoader(_en),
    child: ProviderScope(
      overrides: [...overrides],
      child: Builder(
        builder: (context) => MaterialApp(
          theme: appLightTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: home,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Color? _textColor(WidgetTester tester, Key key) => tester.widget<Text>(find.byKey(key)).style?.color;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _en = jsonDecode(await rootBundle.loadString('$langPath/en.json')) as Map<String, dynamic>;
  });

  group('change club type DTOs', () {
    test('request sends the numeric club type', () {
      expect(ChangeClubTypeRequest(clubId: "c1", newClubType: ClubType.nonListedClub).toJson(), {"ClubId": "c1", "NewClubType": 2});
      expect(ChangeClubTypeRequest(clubId: "c1", newClubType: ClubType.publicClub).toJson()["NewClubType"], 1);
    });

    test('response parses numeric and named types', () {
      final r = ChangeClubTypeResponse.fromJson({"ResultCode": 0, "ClubId": "c1", "PreviousClubType": 1, "NewClubType": "NonListedClub"});
      expect(r.clubId, "c1");
      expect(r.previousClubType, ClubType.publicClub);
      expect(r.newClubType, ClubType.nonListedClub);
      expect(r.errors, isEmpty);
      expect(ChangeClubTypeResponse.fromJson({"ResultCode": 0}).newClubType, isNull);
    });
  });

  group('DeleteClub page', () {
    testWidgets('only title, icon and warning sentence are red; password is the personal login password', (tester) async {
      await _pump(tester, const DeleteClub(clubId: "c1", clubName: "My Club"));

      expect(_textColor(tester, const Key("deleteClubTitle")), primaryWarningButtonEnabledColorLight);
      expect(_textColor(tester, const Key("deleteClubWarning")), primaryWarningButtonEnabledColorLight);
      expect(find.text('Warning! The club "My Club" will be deleted.'), findsOneWidget);
      expect(_textColor(tester, const Key("deleteClubConsequences")), isNot(primaryWarningButtonEnabledColorLight));

      expect(find.text("Your login password"), findsOneWidget);
      expect(find.text("Not the club password: the password you use to sign in to FlySafe."), findsOneWidget);
      expect(find.text("DangerZone"), findsNothing);
    });

    testWidgets('button enables only when the name matches and a password is entered; disabled is grey', (tester) async {
      await _pump(tester, const DeleteClub(clubId: "c1", clubName: "My Club"));
      ElevatedButton button() => tester.widget<ElevatedButton>(find.byKey(const Key("deleteClubButton")));

      expect(button().onPressed, isNull);
      final disabledBg = button().style!.backgroundColor!.resolve({WidgetState.disabled});
      expect(disabledBg, Colors.grey.shade300);

      await tester.enterText(find.byKey(const Key("deleteClubNameField")), "  my club ");
      await tester.pump();
      expect(button().onPressed, isNull);

      await tester.enterText(find.byKey(const Key("deleteClubPasswordField")), "x");
      await tester.pump();
      expect(button().onPressed, isNotNull);
      expect(button().style!.backgroundColor!.resolve({}), primaryWarningButtonEnabledColorLight);

      await tester.enterText(find.byKey(const Key("deleteClubNameField")), "my clu");
      await tester.pump();
      expect(button().onPressed, isNull);
    });
  });

  group('ClubDetails', () {
    List detailsOverrides(_FakeClubBackEnd backEnd, List<String> roles) => [
          backEndClub.overrideWithValue(backEnd),
          clubDetailsRequestProvider.overrideWith((ref) => ClubDetailsRequest(clubId: "c1", requestedActions: const [])),
          getUserProfileProvider.overrideWith((ref) => Completer<UserProfileResponse>().future),
          getClubsRolesActionsProvider.overrideWith((ref) async => GetClubsRolesActionsResponse(
                resultCode: AppResultCode.ok,
                allowedActions: AllowedActionsDTO(allowedActions: const []),
                clubAndRoleDTOList: [
                  ClubAndRoleDTO(
                      clubID: "c1", clubType: backEnd.type, clubName: "Test Club", clubComment: "", roles: roles.map((r) => Tuple("id-$r", r)).toList()),
                ],
                errors: const [],
              )),
        ];

    testWidgets('lists every role on its own line under one Roles row', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, ["ReadClubBaseInfo"]);
      await _pump(tester, const ClubDetails(clubId: "c1"), overrides: detailsOverrides(backEnd, ["Club_Owner", "Club_Member"]));

      final row = find.byKey(const Key("clubRolesRow"));
      expect(row, findsOneWidget);
      expect(find.descendant(of: row, matching: find.text("Roles")), findsOneWidget);
      final roleTexts = tester.widgetList<Text>(find.descendant(of: row, matching: find.byType(Text))).map((t) => t.data).toList();
      expect(roleTexts.length, 3); //label + 2 roles
      expect(roleTexts.where((t) => t!.contains(",")), isEmpty);
      expect(find.descendant(of: row, matching: find.text("Owner")), findsOneWidget);
      expect(find.descendant(of: row, matching: find.text("Member")), findsOneWidget);
      expect(find.text("Test Club"), findsOneWidget); //card title only, not repeated as a row
    });

    testWidgets('club type is read-only and Leave/Delete are hidden without permissions', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, ["ReadClubBaseInfo"]);
      await _pump(tester, const ClubDetails(clubId: "c1"), overrides: detailsOverrides(backEnd, ["Club_Member"]));

      final row = tester.widget<ListTile>(find.byKey(const Key("clubTypeRow")));
      expect(row.onTap, isNull);
      expect(row.trailing, isNull);
      expect(find.text("Leave Club"), findsNothing);
      expect(find.text("Delete Club"), findsNothing);
      expect(find.text("Role"), findsOneWidget);
    });

    testWidgets('owner changes the club type, the details refresh and a snackbar is shown', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, ["ReadClubBaseInfo", "EditClubBaseInfo", "DeleteClub"]);
      await _pump(tester, const ClubDetails(clubId: "c1"), overrides: detailsOverrides(backEnd, ["Club_Owner"]));
      expect(find.text("Public (listed)"), findsOneWidget);
      expect(find.text("Delete Club"), findsOneWidget);
      final callsBefore = backEnd.detailsCalls;

      await tester.tap(find.byKey(const Key("clubTypeRow")));
      await tester.pumpAndSettle();
      expect(find.text("Change Club Type"), findsOneWidget);

      ElevatedButton save() => tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, "Save"));
      expect(save().onPressed, isNull); //nothing changed yet

      await tester.tap(find.text("Private (not listed)").last);
      await tester.pump();
      expect(save().onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, "Save"));
      await tester.pumpAndSettle();

      expect(backEnd.lastChange?.newClubType, ClubType.nonListedClub);
      expect(find.text("Club type has been changed"), findsOneWidget);
      expect(backEnd.detailsCalls, greaterThan(callsBefore));
      expect(find.text("Private (not listed)"), findsOneWidget);
    });
  });

  group('club member DTOs', () {
    test('requests use the PascalCase contract', () {
      expect(GetClubMembersRequest(clubId: "c1").toJson(), {"ClubId": "c1"});
      expect(AddClubMemberRequest(clubId: "c1", userNameOrEmail: "a@b.c").toJson(), {"ClubId": "c1", "UserNameOrEmail": "a@b.c"});
      expect(SetClubMemberRoleRequest(clubId: "c1", userId: "u2", role: "Club_Manager").toJson(), {"ClubId": "c1", "UserId": "u2", "Role": "Club_Manager"});
      expect(RemoveClubMemberRequest(clubId: "c1", userId: "u2").toJson(), {"ClubId": "c1", "UserId": "u2"});
    });

    test('member list parses without ResultCode; 409 bodies become conflicts', () {
      final r = GetClubMembersResponse.fromJson({
        "ClubId": "c1",
        "CanAddMember": true,
        "Members": [
          {"UserId": "u1", "UserName": "me", "Role": "Club_Owner", "IsCurrentUser": true, "AllowedRoles": [], "CanRemove": false},
          {"UserId": "u2", "UserName": "you", "Role": "Club_Member", "IsCurrentUser": false, "AllowedRoles": ["Club_Owner", "Club_Manager"], "CanRemove": true},
        ]
      });
      expect(r.resultCode, AppResultCode.ok);
      expect(r.canAddMember, isTrue);
      expect(r.members.map((m) => m.userName), ["me", "you"]);
      expect(r.members.first.isManageable, isFalse);
      expect(r.members.last.allowedRoles, ["Club_Owner", "Club_Manager"]);
      expect(r.members.last.isManageable, isTrue);

      final c = ClubMemberChangeResponse.fromJson({
        "Errors": [
          {"Code": "MemberRankTooHigh", "Description": "x"}
        ]
      }, statusCode: 409);
      expect(c.resultCode, AppResultCode.conflict);
      expect(c.errors.single.code, "MemberRankTooHigh");
    });
  });

  group('Club members', () {
    List membersOverrides(_FakeClubBackEnd backEnd) => [backEndClub.overrideWithValue(backEnd)];
    Finder memberRow(String id) => find.byKey(Key("member_$id"));

    testWidgets('club details shows the Members row only with GetClubMembers', (tester) async {
      for (final actions in [
        ["ReadClubBaseInfo"],
        ["ReadClubBaseInfo", "GetClubMembers"]
      ]) {
        final backEnd = _FakeClubBackEnd(ClubType.publicClub, actions);
        await _pump(tester, ClubDetails(key: UniqueKey(), clubId: "c1"), overrides: [
          backEndClub.overrideWithValue(backEnd),
          clubDetailsRequestProvider.overrideWith((ref) => ClubDetailsRequest(clubId: "c1", requestedActions: const [])),
          getUserProfileProvider.overrideWith((ref) => Completer<UserProfileResponse>().future),
          getClubsRolesActionsProvider.overrideWith((ref) => Completer<GetClubsRolesActionsResponse>().future),
        ]);
        expect(find.byKey(const Key("clubMembersRow")), actions.contains("GetClubMembers") ? findsOneWidget : findsNothing);
      }
      await tester.tap(find.byKey(const Key("clubMembersRow")));
      await tester.pumpAndSettle();
      expect(find.byType(ClubMembers), findsOneWidget);
    });

    testWidgets('lists names and roles, marks the current user and offers actions only where allowed', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const []);
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      expect(find.textContaining("smokepilot  (You)", findRichText: true), findsOneWidget);
      expect(find.textContaining("@"), findsNothing); //no emails
      expect(find.descendant(of: memberRow("u3"), matching: find.text("Manager")), findsOneWidget);
      //self and the other Owner: no chevron, not tappable
      for (final id in ["u1", "u2"]) {
        final tile = tester.widget<ListTile>(memberRow(id));
        expect(tile.onTap, isNull, reason: id);
        expect(tile.trailing, isNull, reason: id);
      }
      for (final id in ["u3", "u4"]) {
        expect(tester.widget<ListTile>(memberRow(id)).onTap, isNotNull, reason: id);
      }
      expect(find.byKey(const Key("addMemberRow")), findsOneWidget);
    });

    testWidgets('no Add member and no actions when the server allows nothing', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const [])..mockMemberRoles["u1"] = ClubMemberDTO.member;
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      expect(find.byKey(const Key("addMemberRow")), findsNothing);
      expect(find.byIcon(chevronExpand), findsNothing);
    });

    testWidgets('add member shows the neutral message and refreshes the list', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const []);
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      await tester.tap(find.byKey(const Key("addMemberRow")));
      await tester.pumpAndSettle();
      ElevatedButton add() => tester.widget<ElevatedButton>(find.byKey(const Key("addMemberButton")));
      expect(add().onPressed, isNull);
      await tester.enterText(find.byKey(const Key("addMemberField")), "   ");
      await tester.pump();
      expect(add().onPressed, isNull); //blank input does not count
      await tester.enterText(find.byKey(const Key("addMemberField")), "  newpilot  ");
      await tester.pump();
      expect(add().onPressed, isNotNull);

      await tester.tap(find.byKey(const Key("addMemberButton")));
      await tester.pumpAndSettle();

      expect(find.text("If a user with this name or email exists, they are now a member."), findsOneWidget);
      expect(find.byType(ClubMembers), findsOneWidget);
      expect(find.text("newpilot"), findsOneWidget);
    });

    testWidgets('change role offers the allowed roles, saves and refreshes', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const []);
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      await tester.tap(memberRow("u4"));
      await tester.pumpAndSettle();
      expect(find.text("lonepilot"), findsOneWidget); //member page title
      await tester.tap(find.byKey(const Key("memberRoleRow")));
      await tester.pumpAndSettle();

      for (final role in ["Club_Owner", "Club_Manager", "Club_Member"]) {
        expect(find.byKey(Key("roleOption_$role")), findsOneWidget);
      }
      ElevatedButton save() => tester.widget<ElevatedButton>(find.byKey(const Key("saveRoleButton")));
      expect(save().onPressed, isNull);
      await tester.tap(find.byKey(const Key("roleOption_Club_Manager")));
      await tester.pump();
      await tester.tap(find.byKey(const Key("saveRoleButton")));
      await tester.pumpAndSettle();

      expect(backEnd.mockMemberRoles["u4"], ClubMemberDTO.manager);
      expect(find.text("Role changed"), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key("memberRoleRow")), matching: find.text("Manager")), findsOneWidget);
    });

    testWidgets('a refused role change shows the translated reason', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const [])..refuseRoleChangeWith = "MemberRankTooHigh";
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      await tester.tap(memberRow("u3"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("memberRoleRow")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("roleOption_Club_Member")));
      await tester.pump();
      await tester.tap(find.byKey(const Key("saveRoleButton")));
      await tester.pumpAndSettle();

      expect(find.text("You can only manage members with a lower role than yours."), findsOneWidget);
      expect(find.text("server text"), findsNothing);
    });

    testWidgets('remove: only icon, title and warning are red; removing refreshes the list', (tester) async {
      final backEnd = _FakeClubBackEnd(ClubType.publicClub, const []);
      await _pump(tester, const ClubMembers(clubId: "c1", clubName: "Test Club"), overrides: membersOverrides(backEnd));

      await tester.tap(memberRow("u4"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("removeMemberRow")));
      await tester.pumpAndSettle();

      expect(_textColor(tester, const Key("removeMemberTitle")), primaryWarningButtonEnabledColorLight);
      expect(_textColor(tester, const Key("removeMemberWarning")), primaryWarningButtonEnabledColorLight);
      expect(_textColor(tester, const Key("removeMemberConsequences")), isNot(primaryWarningButtonEnabledColorLight));
      expect(find.text('"lonepilot" will be removed from the club "Test Club".'), findsOneWidget);

      await tester.tap(find.byKey(const Key("removeMemberButton")));
      await tester.pumpAndSettle();

      expect(find.text("Member removed"), findsOneWidget);
      expect(find.byType(ClubMembers), findsOneWidget);
      expect(memberRow("u4"), findsNothing);
    });
  });
}
