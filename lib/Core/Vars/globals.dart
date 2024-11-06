import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:date_format/date_format.dart' as dtf;

import '../Entities/Aux/app_locale.dart';

//app
const AppBuild appBuildE = AppBuild.alpha; //TODO:THIS SHOULD BE CHANGED ONCE COMPILING FOR PRODUCTION
late EndDevice appPlatform;
bool isMobileDevice = false;
const String prodHost = "fellow7000.com";
const String devHost = "dev7000.com.preview.my-hosting-panel.com";
const String locHost = "192.168.178.59:5200";
//const String locHost = "localhost:5200";
final List<Uri> webHosts = [Uri(scheme: "https", path: prodHost), Uri(scheme: "http", path: devHost), Uri(scheme: "http", path: locHost)];
int hostClicks = 0;
const int maxHostClicks = 5;
const String assetFolder = 'assets/';
const String imageFolder = '${assetFolder}images/';
const String appIcon = '${imageFolder}fs_icon.png';
const String copyRightLabel = "© 2017 - 2024 Fellow7000";
const String f7email = "tower@fellow7000.com";
final Uri tutorialUrl = Uri.parse('https://youtu.be/P0wUxeZgop0'); //video tutorial url V 3.2.0
late String clickToRetry;

//date & time
const List<String> dateISO = [dtf.yyyy, '-', dtf.mm, '-', dtf.dd];
const List<String> dateEU = [dtf.dd, '.', dtf.mm, '.', dtf.yyyy];
const List<String> dateUS = [dtf.mm, '/', dtf.dd, '/', dtf.yyyy];
const List<List<String>> dateFormats = [dateISO, dateEU, dateUS];

//user & club
const int minUserPasswordLength = 6;
String accessToken = "";
bool requestStartUpSignIn = false; //if we need to sign-in during app startup of toggling app mode
bool loadUserOrClubProfile = true; //if we need to load user / club profile

//Icons
const double appIconBasisSize = 24;

const IconData loginIcon = Icons.login;
const IconData logOutIcon = Icons.logout;
const IconData chevronExpand = Icons.chevron_right;
const IconData userIcon = Icons.account_circle;
const IconData emailIcon = Icons.email;
const IconData clearTextIcon = Icons.cancel;
const IconData passwordIcon = Icons.security;
const IconData clubIcon = Icons.warehouse;
const IconData retryIcon = Icons.sync;
const IconData visibleIcon = Icons.visibility;
const IconData notVisibleIcon = Icons.visibility_off;
const IconData helpIcon = Icons.help;
const IconData errorIcon = Icons.error;
const IconData calenderIcon = Icons.calendar_month_outlined;
const IconData addObjectIcon = Icons.add;
const IconData joinClubIcon = Icons.input;
const IconData commentIcon = Icons.edit_note;

//window size & margins
late double windowWidth;
late double windowHeight;
late WindowWidth winWidth;
const double standardPanelWidth = 430;
const double panelWidthLarge = 800;
const double formPadding = 15;

//localization & locale
const String en = "en";
const String de = "de";
const String ru = "ru";

const String langPath = 'assets/langs';
final Locale localeEN = Locale(en, en.toUpperCase()); //TODO: check if EN can work instead US
final Locale localeDE = Locale(de, de.toUpperCase());
final Locale localeRU = Locale(ru, ru.toUpperCase());

const String autoLanguage = "AutoLanguage";
const String englishLanguage = "English";
const String germanLanguage = "German";
const String russianLanguage = "Russian";

const List<AppLocale> appLocales = [
  AppLocale(localeName: autoLanguage, locale: Locale('xx', 'XX')),
  AppLocale(localeName: englishLanguage, locale: Locale("en", "EN")),
  AppLocale(localeName: germanLanguage, locale: Locale('de', 'DE')),
  AppLocale(localeName: russianLanguage, locale: Locale('ru', 'RU'))
];

//settings
const double settingsPanelWidthLarge = 800;

//hand-notes
const int rootFolder = 0; //code fo root Folder
const String rootFolderName = "RootFolder";

//global keys
final GlobalKey<ScaffoldState> scaffoldKeySignIn = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldMessengerState> scaffoldKeyDeleteUserAccount = GlobalKey<ScaffoldMessengerState>();
late WidgetRef globalRef;
late BuildContext globalContext;