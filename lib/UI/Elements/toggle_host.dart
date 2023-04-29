import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';

class ToggleHost extends ConsumerWidget {
  const ToggleHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;

    return GestureDetector(
      onTap: () => _toggleHost(ref),
      onLongPress: () => _resetHost(ref),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public, size: iconSize),
          Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(ref.watch(webHostProvider).toString().replaceFirst("https:", "https://").replaceFirst("http:", "http://"),
                  style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeDelta: fontSizeDelta)))
        ],
      ),
    );
  }

  void _toggleHost(WidgetRef ref) {
    if (kDebugMode || hostClicks >= maxHostClicks) {
      int pos = webHosts.indexOf(ref.read(webHostProvider.notifier).state);
      if (pos == webHosts.length - 1) {
        pos = 0;
      } else {
        pos++;
      }
      ref.read(webHostProvider.notifier).state = webHosts[pos];
    } else {
      hostClicks++;
    }
  }

  void _resetHost(WidgetRef ref) {
    if (kDebugMode || hostClicks >= maxHostClicks) {
      ref.read(webHostProvider.notifier).state = webHosts.first;
    }
  }
}
