import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/Vars/providers.dart';

class AppProcessIndicator extends ConsumerWidget {
  final String message;

  const AppProcessIndicator({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deltaFontSize = ref.watch(deltaFontSizeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      const CircularProgressIndicator(),
      const SizedBox(width: 10),
      Text(message, style: Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: deltaFontSize))
    ],);
  }

}