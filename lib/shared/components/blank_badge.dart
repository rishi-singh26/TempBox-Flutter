import 'package:flutter/material.dart';

class BlankBadge extends StatelessWidget {
  final Color? color;
  const BlankBadge({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: color ?? const Color(0XFF0B84FF), shape: const StadiumBorder()),
      height: 12,
      width: 12,
    );
  }
}
