import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../Core/DTO/Base/call_error.dart';

class ApiErrorMessages extends StatelessWidget {
  final List<CallError>? callErrors;
  final double deltaFontSize;

  const ApiErrorMessages({super.key, this.callErrors, required this.deltaFontSize});

  @override
  Widget build(BuildContext context) {
    if (callErrors == null || callErrors!.isEmpty) {
      return Container();
    }

    TextStyle errorTextStyle = Theme.of(context).textTheme.titleMedium!.apply(fontSizeDelta: deltaFontSize, color: Colors.red);

    List<Row> errorList = [];

    for (CallError error in callErrors!) {
      errorList.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: error.localError
            ?Tooltip(
                message: error.description,
                child: Text(error.code.tr(), style: errorTextStyle, textAlign: TextAlign.center))
            :Text(error.description, style: errorTextStyle, textAlign: TextAlign.center),
          ),
        ],
      ));
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(children: errorList,),
        ],
      ),
    );
  }

}