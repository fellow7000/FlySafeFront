import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';

class ThemeModeSwitch extends ConsumerWidget {
  const ThemeModeSwitch({
    super.key,
    required this.textStyle,
    required this.lightModeLabel,
    required this.darkModeLabel,
    required this.systemModeLabel});

  final TextStyle textStyle;
  final String lightModeLabel;
  final String darkModeLabel;
  final String systemModeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _getIcon(ref),
      title: _getTitle(ref),
      onTap: () => _toggleTheme(ref),
    );
  }

  Icon _getIcon(WidgetRef ref) {
    if (ref.watch(themeModeProvider) == ThemeMode.light) {
      return const Icon(Icons.light_mode);
    } else if (ref.watch(themeModeProvider) == ThemeMode.dark) {
      return const Icon(Icons.dark_mode);
    } else {
      return const Icon(Icons.ad_units);
    }
  }

  Widget _getTitle(WidgetRef ref) {
    if (ref.watch(themeModeProvider) == ThemeMode.light) {
      return Text(lightModeLabel, style: textStyle);
    } else if (ref.watch(themeModeProvider) == ThemeMode.dark){
      return Text(darkModeLabel, style: textStyle);
    } else {
      return Text(systemModeLabel, style: textStyle);
    }
  }

  void _toggleTheme(WidgetRef ref) async {
    if (ref.read(themeModeProvider.notifier).state == ThemeMode.light) {
      ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
    } else if (ref.read(themeModeProvider.notifier).state == ThemeMode.dark) {
      ref.read(themeModeProvider.notifier).state = ThemeMode.system;
    } else {
      ref.read(themeModeProvider.notifier).state = ThemeMode.light;
    }
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.themeModePref, prefValue: ref.read(themeModeProvider.notifier).state.name);
  }

}