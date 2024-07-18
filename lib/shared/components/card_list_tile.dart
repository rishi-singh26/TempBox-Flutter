import 'package:flutter/material.dart';

class CardListTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget child;
  final EdgeInsets? margin;
  const CardListTile({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 15),
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 12 : 0),
          topRight: Radius.circular(isFirst ? 12 : 0),
          bottomLeft: Radius.circular(isLast ? 12 : 0),
          bottomRight: Radius.circular(isLast ? 12 : 0),
        ),
      ),
      child: child,
    );
  }
}
