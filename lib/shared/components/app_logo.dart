import 'package:flutter/cupertino.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final BorderRadiusGeometry? borderRadius;
  const AppLogo({super.key, this.size, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 60,
      height: size ?? 60,
      decoration: BoxDecoration(borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8))),
      clipBehavior: Clip.hardEdge,
      child: Image.asset('assets/icon.png'),
    );
  }
}
