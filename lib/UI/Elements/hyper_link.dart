import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HyperLink extends ConsumerWidget {
  final String link;
  final TextStyle? style;
  final isMouseInProvider = StateProvider((ref) => false);

  HyperLink({
    Key? key,
    required this.link,
    required this.style
  }) : super (key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      onEnter: (pointerEvenValue) => ref.read(isMouseInProvider.notifier).state = true,
      onExit: (pointerEvenValue) => ref.read(isMouseInProvider.notifier).state = false,
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(link, style: style!.apply(decoration: ref.watch(isMouseInProvider)?TextDecoration.underline:TextDecoration.none))),
    );
  }
}