import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Helpers/app_helper.dart';
import '../Themes/app_themes.dart';

class BasisForm extends ConsumerWidget {
  final String formTitle;
  final Widget form;

  BasisForm({super.key, this.formTitle = "", Widget? form}) : form=form??Container();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color appBarIconColor = Theme.of(context).brightness == Brightness.light ? appBarIconColorLight : appBarIconColorDark;

    return SafeArea(
      child: GestureDetector(
        onTap: () => AppHelper.dismissKeyboard(context),
        child: Scaffold(
          appBar: AppBar(
            title: FittedBox(fit: BoxFit.scaleDown, child: Text(formTitle)),
            leading: IconButton(icon: const Icon(Icons.arrow_back), color: appBarIconColor, onPressed: () => Navigator.pop(context, false)),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: winWidth == WindowWidth.small?windowWidth : standardPanelWidth,
                child: Column(
                  children: [form],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}