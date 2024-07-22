import 'dart:ui';

import 'package:flutter/cupertino.dart';

class BlurredContainer extends StatelessWidget {
  final Widget child;
  final Size size;
  final BorderRadiusGeometry borderRadius;
  final ImageFilter filter;
  const BlurredContainer({
    super.key,
    required this.child,
    required this.size,
    required this.filter,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: filter,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? CupertinoColors.black.withOpacity(0.2)
                  : CupertinoColors.white.withOpacity(0.2)),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
