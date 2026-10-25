import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/DTO/Club/change_club_password_request.dart';
import 'package:fs_front/Core/DTO/Club/change_club_password_response.dart';
import 'package:fs_front/Core/DTO/Club/delete_club_request.dart';
import 'package:fs_front/Core/DTO/Club/delete_club_response.dart';
import 'package:fs_front/Core/DTO/Club/leave_club_request.dart';
import 'package:fs_front/Core/DTO/Club/leave_club_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/UI/Clubs/club_action_dialogs.dart';
import 'package:fs_front/UI/Elements/password_change_fields.dart';

void main() {
  group('club management DTOs', () {
    test('requests use PascalCase keys', () {
      expect(LeaveClubRequest(clubId: "c1").toJson(), {"ClubId": "c1"});
      expect(DeleteClubRequest(clubId: "c1", clubNameConfirmation: "N", userPassword: "p").toJson(),
          {"ClubId": "c1", "ClubNameConfirmation": "N", "UserPassword": "p"});
      expect(ChangeClubPasswordRequest(clubId: "c1", oldClubPassword: "", newClubPassword: "").toJson(),
          {"ClubId": "c1", "OldClubPassword": "", "NewClubPassword": ""});
    });

    test('responses parse result, ids and errors', () {
      final leave = LeaveClubResponse.fromJson({
        "ResultCode": 0,
        "ClubId": "c1",
        "Errors": [
          {"Code": "LastOwnerCannotLeave", "Description": "d"}
        ]
      });
      expect(leave.clubId, "c1");
      expect(leave.errors.single.code, "LastOwnerCannotLeave");

      final del = DeleteClubResponse.fromJson({"ResultCode": 0, "ClubId": "c1", "DeletedOn": "2026-10-25T10:00:00Z"});
      expect(del.deletedOn, DateTime.utc(2026, 10, 25, 10));
      expect(DeleteClubResponse.fromJson({"ResultCode": 0}).deletedOn, isNull);

      final change = ChangeClubPasswordResponse.fromJson({"ResultCode": 0, "ClubId": "c1"});
      expect(change.clubId, "c1");
      expect(change.errors, isEmpty);
      expect(change.resultCode, getAppResultEnum(0));
    });
  });

  test('delete confirmation ignores case and surrounding spaces', () {
    expect(DeleteClubDialog.isClubNameConfirmed("  my club ", "My Club"), isTrue);
    expect(DeleteClubDialog.isClubNameConfirmed("my clu", "My Club"), isFalse);
  });

  group('PasswordChangeFields.isInputValid', () {
    bool valid(String cur, String neu, String conf, {int min = 6, bool allowEmpty = false}) =>
        PasswordChangeFields.isInputValid(current: cur, newPassword: neu, confirmation: conf, minLength: min, allowEmptyCurrent: allowEmpty);

    test('enforces minimum length and confirmation', () {
      expect(valid("x", "123456", "123456"), isTrue);
      expect(valid("x", "12345", "12345"), isFalse);
      expect(valid("x", "123456", "123457"), isFalse);
      expect(valid("x", "", ""), isFalse);
    });

    test('current password may be empty only when allowed', () {
      expect(valid("", "123456", "123456"), isFalse);
      expect(valid("", "123456", "123456", allowEmpty: true), isTrue);
    });

    test('without minimum length an empty new password is valid', () {
      expect(valid("", "", "", min: 0, allowEmpty: true), isTrue);
      expect(valid("", "a", "", min: 0, allowEmpty: true), isFalse);
    });
  });

  testWidgets('PasswordChangeFields reports validity changes', (tester) async {
    final current = TextEditingController();
    final newPwd = TextEditingController();
    final confirm = TextEditingController();
    addTearDown(current.dispose);
    addTearDown(newPwd.dispose);
    addTearDown(confirm.dispose);
    final reports = <bool>[];

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PasswordChangeFields(
            currentController: current,
            newController: newPwd,
            confirmController: confirm,
            currentLabel: "cur",
            newLabel: "new",
            confirmLabel: "conf",
            minLength: 0,
            maxLength: 5,
            allowEmptyCurrent: true,
            onValidityChanged: reports.add,
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(reports, [true]);

    await tester.enterText(find.widgetWithText(TextField, "new"), "abc");
    await tester.pump();
    expect(reports.last, isFalse);

    await tester.enterText(find.widgetWithText(TextField, "conf"), "abc");
    await tester.pump();
    expect(reports.last, isTrue);

    await tester.enterText(find.widgetWithText(TextField, "new"), "abcdefgh");
    await tester.pump();
    expect(newPwd.text, "abcde"); //max length
  });
}
