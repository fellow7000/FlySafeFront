import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_requrest.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_response.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';
import 'package:fs_front/main.dart';

void main() {
  test('failed sign-in waits for an explicit retry', () async {
    final api = _FailingIdentityApi();
    final container = createAppContainer(
      overrides: [backEndUser.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    container
        .read(authentificationRequestProvider.notifier)
        .state = AuthentificationRequest(
      userNameOrEmail: 'test-pilot',
      password: 'test-only-password',
      passwordType: PasswordType.plainText,
      logAs: LogAs.user,
      returnPasswordHash: false,
      endDevice: EndDevice.android,
      keepSignedIn: false,
    );
    final subscription = container.listen(signInProvider, (_, _) {});
    addTearDown(subscription.close);
    await expectLater(container.read(signInProvider.future), throwsA(anything));
    // Riverpod 3's default first automatic retry is after 200 ms.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(api.attempts, 1);
    container.invalidate(signInProvider);
    await expectLater(container.read(signInProvider.future), throwsA(anything));
    expect(api.attempts, 2);
  });

  testWidgets('the clock receives distinct events on every second', (
    tester,
  ) async {
    final container = createAppContainer();
    addTearDown(container.dispose);
    final ticks = <int>[];
    final subscription = container.listen(dateTimeTickerProvider, (_, value) {
      if (value.hasValue) ticks.add(value.requireValue);
    });
    addTearDown(subscription.close);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(ticks, [0, 1, 2]);
    subscription.close();
    container.dispose();
    await tester.pump();
  });
}

class _FailingIdentityApi extends Fake implements IApiIdentity {
  int attempts = 0;
  @override
  Future<AuthentificationResponse> signIn({
    required AuthentificationRequest authentificationRequest,
  }) async {
    attempts++;
    throw Exception('Simulated offline response');
  }
}
