import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String orLabel;

  const OrDivider({super.key, required this.orLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Row(
        children: [
          const Expanded(
              child: Divider(
                thickness: 2,
                height: 2,
              )),
          Padding(padding: const EdgeInsets.only(left: 5, right: 5), child: Text(orLabel)),
          const Expanded(
            child: Divider(
              thickness: 2,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }
}