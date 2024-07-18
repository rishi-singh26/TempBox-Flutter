import 'package:flutter/material.dart';

class PaddedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  const PaddedCard({super.key, required this.child, this.contentPadding, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        child: Padding(padding: contentPadding ?? const EdgeInsets.all(0), child: child),
      ),
    );
  }
}
