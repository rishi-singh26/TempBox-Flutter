// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class SVGIcon extends StatelessWidget {
//   final String asset;
//   final bool useColor;
//   final Color? color;
//   final Size? size;
//   const SVGIcon({super.key, required this.asset, this.color, this.size, this.useColor = true});

//   @override
//   Widget build(BuildContext context) {
//     Brightness brightness = Theme.of(context).brightness;
//     return SvgPicture.asset(
//       asset,
//       width: size?.width ?? 25.0,
//       height: size?.height ?? 25.0,
//       colorFilter: useColor
//           ? ColorFilter.mode(
//               color ?? (brightness == Brightness.dark ? Colors.white : Colors.black),
//               BlendMode.srcIn,
//             )
//           : null,
//     );
//   }
// }
