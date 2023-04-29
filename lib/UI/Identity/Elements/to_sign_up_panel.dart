import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Core/Vars/providers.dart';
import '../../Elements/hyper_link.dart';

class ToSignUpOrIn extends ConsumerWidget {
  final String haveAccountLabel;
  final String signUpInLabel;
  final String? itsFreeLabel;
  final Function toggleUpIn;

  const ToSignUpOrIn({Key? key, required this.haveAccountLabel, required this.signUpInLabel, this.itsFreeLabel, required this.toggleUpIn}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 3,
            child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Text(haveAccountLabel, style: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: fontSizeDelta)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: GestureDetector(
                              onTap: () => toggleUpIn(),
                              child: HyperLink(
                                link: signUpInLabel,
                                style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.blue, fontSizeDelta: fontSizeDelta),
                              )),
                        ),
                      ],
                    ),
                    if (itsFreeLabel!=null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        itsFreeLabel!,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: fontSizeDelta),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
