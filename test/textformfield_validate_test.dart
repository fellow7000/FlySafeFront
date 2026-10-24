import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/DTO/Generic/check_value_request.dart';
import 'package:fs_front/Core/DTO/Generic/check_value_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Infrastructure/BackEnd/GenericCalls/i_api_generic.dart';
import 'package:fs_front/Infrastructure/BackEnd/backend_call.dart';
import 'package:fs_front/UI/Elements/textformfield_validate.dart';

const _debounce = TextFormFieldOnlineValidate.defaultDebounce;

void main() {
  late _FakeApiGeneric api;
  late StateProvider<bool> isValid;
  late StateProvider<ValidationStatus> status;
  late StateProvider<String> stamp;
  late StateProvider<CheckValueRequest?> endpoint;
  late TextEditingController controller;
  late ProviderContainer container;

  Future<void> pumpField(WidgetTester tester, {bool allowEmptyValue = false}) async {
    api = _FakeApiGeneric();
    isValid = StateProvider<bool>((ref) => false);
    status = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);
    stamp = StateProvider<String>((ref) => "");
    endpoint = StateProvider<CheckValueRequest?>((ref) => const CheckValueRequest(
        value: "", timeStamp: "", apiController: "api/club", apiHandler: "checkclubnamefree", isAuthorized: true));
    controller = TextEditingController();
    addTearDown(controller.dispose);
    container = ProviderContainer(overrides: [backEndGeneric.overrideWithValue(api)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: TextFormFieldOnlineValidate(
            validationType: ValidationType.field,
            fieldNotValidLabel: "taken",
            isFieldValidProvider: isValid,
            controller: controller,
            prefixIcon: Icons.group,
            checkValueRequestProvider: endpoint,
            validationStateProvider: status,
            timeStampChecker: stamp,
            allowEmptyValue: allowEmptyValue,
          ),
        ),
      ),
    ));
  }

  testWidgets('rapid typing sends one trimmed request after the pause', (tester) async {
    await pumpField(tester);

    for (final text in ['S', 'Sm', 'Smo', '  Smoke Club  ']) {
      await tester.enterText(find.byType(TextFormField), text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(api.requests, isEmpty);
    expect(container.read(status), ValidationStatus.validating);
    expect(container.read(isValid), isFalse);

    await tester.pump(_debounce);
    expect(api.requests.map((r) => r.value), ['Smoke Club']);
    expect(api.requests.single.apiHandler, 'checkclubnamefree');
    expect(api.requests.single.isAuthorized, isTrue);

    api.answer(0, isValueValid: true);
    await tester.pump();
    expect(container.read(status), ValidationStatus.ok);
    expect(container.read(isValid), isTrue);
  });

  testWidgets('a taken value is reported as not valid', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    await tester.pump(_debounce);
    api.answer(0, isValueValid: false);
    await tester.pump();

    expect(container.read(status), ValidationStatus.notValid);
    expect(container.read(isValid), isFalse);
    expect(find.text('taken'), findsOneWidget);
  });

  testWidgets('answers to older values are ignored', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'Smoke');
    await tester.pump(_debounce);
    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    await tester.pump(_debounce);
    expect(api.requests.map((r) => r.value), ['Smoke', 'Smoke Club']);

    api.answer(1, isValueValid: true);
    await tester.pump();
    api.answer(0, isValueValid: false);
    await tester.pump();

    expect(container.read(status), ValidationStatus.ok);
    expect(container.read(isValid), isTrue);
  });

  testWidgets('an answer in flight is dropped when the user keeps typing', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'Smoke');
    await tester.pump(_debounce);
    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    api.answer(0, isValueValid: true);
    await tester.pump();

    expect(container.read(status), ValidationStatus.validating);
    expect(container.read(isValid), isFalse);
    await tester.pump(_debounce);
  });

  testWidgets('rate limiting shows a failed state', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    await tester.pump(_debounce);
    api.answerTooManyRequests(0);
    await tester.pump();

    expect(container.read(status), ValidationStatus.failed);
    expect(container.read(isValid), isFalse);
    expect(find.text('TooManyRequests'), findsOneWidget);
  });

  testWidgets('a failing call shows a failed state', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    await tester.pump(_debounce);
    api.fail(0);
    await tester.pump();

    expect(container.read(status), ValidationStatus.failed);
    expect(container.read(isValid), isFalse);
    expect(find.text('ValidationError'), findsOneWidget);
  });

  testWidgets('blank input is decided locally', (tester) async {
    await pumpField(tester);
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pump(_debounce);
    expect(api.requests, isEmpty);
    expect(container.read(status), ValidationStatus.notValid);
    expect(container.read(isValid), isFalse);

    await pumpField(tester, allowEmptyValue: true);
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pump(_debounce);
    expect(api.requests, isEmpty);
    expect(container.read(status), ValidationStatus.ok);
    expect(container.read(isValid), isTrue);
  });

  testWidgets('a pending check is cancelled when the field is removed', (tester) async {
    await pumpField(tester);
    await tester.enterText(find.byType(TextFormField), 'Smoke Club');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(_debounce);
    expect(api.requests, isEmpty);
  });
}

class _FakeApiGeneric implements IApiGeneric {
  final requests = <CheckValueRequest>[];
  final _pending = <Completer<CheckValueResponse>>[];

  @override
  Future<CheckValueResponse> checkValue({required CheckValueRequest checkValueRequest}) {
    requests.add(checkValueRequest);
    final completer = Completer<CheckValueResponse>();
    _pending.add(completer);
    return completer.future;
  }

  void answer(int index, {required bool isValueValid}) => _pending[index].complete(CheckValueResponse(
      resultCode: AppResultCode.ok, isValueValid: isValueValid, timeStamp: requests[index].timeStamp, errors: const []));

  void answerTooManyRequests(int index) => _pending[index].complete(CheckValueResponse(
      resultCode: AppResultCode.conflict,
      isValueValid: false,
      timeStamp: requests[index].timeStamp,
      errors: const [BackEndCall.tooManyRequestsError]));

  void fail(int index) => _pending[index].completeError(Exception('network down'));
}
