import 'package:flutter/cupertino.dart';

class MacosCard extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final EdgeInsets padding;

  final Widget child;
  const MacosCard({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 8 : 0),
          topRight: Radius.circular(isFirst ? 8 : 0),
          bottomLeft: Radius.circular(isLast ? 8 : 0),
          bottomRight: Radius.circular(isLast ? 8 : 0),
        ),
        color: CupertinoColors.systemGrey5.resolveFrom(context),
      ),
      child: child,
    );
  }
}
