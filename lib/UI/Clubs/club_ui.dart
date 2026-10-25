import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../Core/Vars/globals.dart';
import '../Themes/app_themes.dart';

///Small progress indicator that replaces the confirm button of a dialog while the call runs.
const clubDialogProgress = Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));

///Theme-aware styles for the club screens.
///The global textStyle* variables are initialised above MaterialApp and keep the light-theme text colour, so they are invisible in dark mode.
class ClubStyles {
  final TextStyle label; //info row label
  final TextStyle value; //info row value and navigation row title
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle buttonLabel; //no colour: inherits the button foreground (enabled / disabled)
  final double iconSize;
  final Color danger; //red for the warning icon, sentence and title on a surface
  final bool isLight;

  const ClubStyles._(
      {required this.label,
      required this.value,
      required this.cardTitle,
      required this.body,
      required this.buttonLabel,
      required this.iconSize,
      required this.danger,
      required this.isLight});

  factory ClubStyles.of(BuildContext context, double fontSizeDelta) {
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final button = textTheme.headlineSmall!.apply(fontSizeDelta: fontSizeDelta);
    return ClubStyles._(
      label: textTheme.titleMedium!.apply(fontSizeDelta: fontSizeDelta),
      value: textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta),
      cardTitle: textTheme.headlineSmall!.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta),
      body: textTheme.titleMedium!.apply(fontSizeDelta: fontSizeDelta),
      buttonLabel: TextStyle(fontSize: button.fontSize, fontWeight: button.fontWeight, height: button.height, letterSpacing: button.letterSpacing),
      iconSize: appIconBasisSize + fontSizeDelta,
      danger: isLight ? primaryWarningButtonEnabledColorLight : Colors.red.shade400,
      isLight: isLight,
    );
  }

  ///Red button with a white label when enabled, plain grey with a legible dark/light label when disabled (no pink).
  ButtonStyle get destructiveButton => ElevatedButton.styleFrom(
        backgroundColor: isLight ? primaryWarningButtonEnabledColorLight : Colors.red.shade700,
        foregroundColor: Colors.white,
        disabledBackgroundColor: isLight ? Colors.grey.shade300 : Colors.grey.shade800,
        disabledForegroundColor: isLight ? Colors.grey.shade800 : Colors.grey.shade300,
      );

  ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: isLight ? primaryActionButtonDefEnabledColorLight : primaryActionButtonDefEnabledColorDark,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryActionButtonDefDisabledColor,
        disabledForegroundColor: Colors.white,
      );
}

///Card with the standard elevation and padding of a form.
class ClubCard extends StatelessWidget {
  const ClubCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(formPadding), child: Column(children: children))),
      const Padding(padding: EdgeInsets.only(top: formPadding)),
    ]);
  }
}

///All roles of the user in a club, one per line, so several roles never overflow a single line.
class ClubRolesText extends StatelessWidget {
  const ClubRolesText({required this.roleNames, required this.style, super.key});

  final List<String> roleNames;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: roleNames.map((r) => Text(r.tr(), style: style)).toList(),
    );
  }
}
