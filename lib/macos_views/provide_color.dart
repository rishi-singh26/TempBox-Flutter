import 'dart:ui';

import 'package:macos_ui/macos_ui.dart';

class ProvideColor {
  /// Returns the selected color based on the provided parameters.
  static Color getSelectedColor({
    required AccentColor accentColor,
    required bool isDarkModeEnabled,
    required bool isWindowMain,
  }) {
    if (isDarkModeEnabled) {
      if (!isWindowMain) {
        return const MacosColor.fromRGBO(76, 78, 65, 1.0);
      }

      switch (accentColor) {
        case AccentColor.blue:
          return const MacosColor.fromRGBO(22, 105, 229, 0.749);

        case AccentColor.purple:
          return const MacosColor.fromRGBO(204, 45, 202, 0.749);

        case AccentColor.pink:
          return const MacosColor.fromRGBO(229, 74, 145, 0.749);

        case AccentColor.red:
          return const MacosColor.fromRGBO(238, 64, 68, 0.749);

        case AccentColor.orange:
          return const MacosColor.fromRGBO(244, 114, 0, 0.749);

        case AccentColor.yellow:
          return const MacosColor.fromRGBO(233, 176, 0, 0.749);

        case AccentColor.green:
          return const MacosColor.fromRGBO(76, 177, 45, 0.749);

        case AccentColor.graphite:
          return const MacosColor.fromRGBO(129, 129, 122, 0.824);
      }
    }

    if (!isWindowMain) {
      return const MacosColor.fromRGBO(213, 213, 208, 1.0);
    }

    switch (accentColor) {
      case AccentColor.blue:
        return const MacosColor.fromRGBO(9, 129, 255, 0.749);

      case AccentColor.purple:
        return const MacosColor.fromRGBO(162, 28, 165, 0.749);

      case AccentColor.pink:
        return const MacosColor.fromRGBO(234, 81, 152, 0.749);

      case AccentColor.red:
        return const MacosColor.fromRGBO(220, 32, 40, 0.749);

      case AccentColor.orange:
        return const MacosColor.fromRGBO(245, 113, 0, 0.749);

      case AccentColor.yellow:
        return const MacosColor.fromRGBO(240, 180, 2, 0.749);

      case AccentColor.green:
        return const MacosColor.fromRGBO(66, 174, 33, 0.749);

      case AccentColor.graphite:
        return const MacosColor.fromRGBO(174, 174, 167, 0.847);
    }
  }
}
