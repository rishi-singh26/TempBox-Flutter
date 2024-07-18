import 'package:flutter/material.dart';

class PaddedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? color;
  const PaddedCard({super.key, required this.child, this.contentPadding, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        color: color,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(padding: contentPadding ?? const EdgeInsets.all(0), child: child),
      ),
    );
  }
}
