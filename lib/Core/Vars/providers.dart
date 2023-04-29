import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/user_profile_response.dart';
import 'package:fs_front/Core/Entities/Aux/app_locale.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/Infrastructure/BackEnd/GenericCalls/api_generic.dart';
import 'package:fs_front/Infrastructure/BackEnd/IdentityCalls/api_identity.dart';
import '../../Infrastructure/BackEnd/ClubCalls/api_club.dart';
import '../../Infrastructure/BackEnd/ClubCalls/i_api_club.dart';
import '../../Infrastructure/BackEnd/GenericCalls/i_api_generic.dart';
import '../../Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';
import 'globals.dart';

//app
final appModeProvider = StateProvider((ref) => AppMode.online);
final appLocaleProvider = StateProvider<AppLocale>((ref) => appLocales.first); //init with auto locale
final webHostProvider = StateProvider<Uri>((ref) => webHosts.first);
final isShowStartDialogProvider = StateProvider((ref) => true); //if warning dialog shall be shown on each app start
final isStartConfirmedProvider = StateProvider((ref) => false); //if app start is confirmed either in start dialog or by unchecking the checkbox in start dialog
final isKeepDisplayOnProvider = StateProvider((ref) => false); //for mobile devices only, not for web or Win, Linux or MacOS
final isConfirmationOnExitProvider = StateProvider((ref) => true); //for Android only, not sure for Desktop

//Screen Size etc
//var winWidthProvider = StateProvider((ref) => WindowWidth.small);

//Date & Time
final dateTimeOrderProvider = StateProvider((ref) => DateTimeOrder.timeDate);
final dateFormatProvider = StateProvider((ref) => dateISO);

final dateTimeTickerProvider = StreamProvider((ref) {
  return Stream.periodic(const Duration(seconds: 1));
});

final dateTimeLocProvider = StateProvider((ref)
{
  ref.watch(dateTimeTickerProvider);
  final dateTimeOrder = ref.watch(dateTimeOrderProvider);
  final dateFormat = ref.watch(dateFormatProvider);

  return AppHelper.getCurrentDateTime(dateTimeType: DateTimeType.loc, dateFormat: dateFormat, dateTimeOrder: dateTimeOrder);
} );

final dateTimeUTCProvider = StateProvider((ref) {
  ref.watch(dateTimeTickerProvider);
  final dateTimeOrder = ref.watch(dateTimeOrderProvider);
  final dateFormat = ref.watch(dateFormatProvider);

  return AppHelper.getCurrentDateTime(dateTimeType: DateTimeType.utc, dateFormat: dateFormat, dateTimeOrder: dateTimeOrder);
});

//Sign-In / Sign-Up
var authStateProvider = StateProvider((ref) => LogAs.none); //if user already signed into the system as a user or a club
var toSignAsProvider = StateProvider((ref) => LogAs.userOrClub); //intention to sign in as user / club in Log-In form
//var requestStartUpSignInProvider = StateProvider<bool>((ref) => false); //if sign-in procedure shall be executed at start-up

//user & club
final userOrClubNameProvider = StateProvider((ref) => "");
final userOrClubHashProvider = StateProvider((ref) => "");
final selectedPublicClubProvider = StateProvider<String?>((ref) => null);

final backEndClub = Provider<IApiClub>((ref) {
  final Uri webHostUri = ref.watch(webHostProvider);
  return ApiClub(webHostUri: webHostUri);});

//on-the-fly Validation
final userNameValidationStampProvider = StateProvider<String>((ref) => DateTime.now().toUtc().toString());
final emailValidationStampProvider = StateProvider<String>((ref) => DateTime.now().toUtc().toString());
final clubNameValidationStampProvider = StateProvider<String>((ref) => DateTime.now().toUtc().toString());

//Implementation with Future
final publicClubsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(backEndClub).getPublicClubs();});

final getUserProfileProvider = FutureProvider.autoDispose<UserProfileResponse>((ref) {
  return ref.watch(backEndUser).getUserProfile();
});

final userProfileProvider = StateProvider<UserProfileResponse?>((ref) => null);

//final backEndUser = Provider<BackEndIdentity>((ref) => FakeBackEndIdentity());
final backEndUser = Provider<IApiIdentity>((ref) {
  final Uri webHostUri = ref.read(webHostProvider.notifier).state;
  return ApiIdentity(webHostUri: webHostUri);
});

final backEndGeneric = Provider<IApiGeneric>((ref) {
  final Uri webHostUri = ref.read(webHostProvider.notifier).state;
  return ApiGeneric(webHostUri: webHostUri);
});

//colors & themes
final themeModeProvider = StateProvider((ref) => ThemeMode.light);
final hoverColorProvider = StateProvider((ref) => Colors.blue[100]);

//fonts and sized
final deltaFontSizeProvider = StateProvider<double>((ref) => 0.0);