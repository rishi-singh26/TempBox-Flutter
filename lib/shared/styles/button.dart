import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle destructive({double radius = 8.0}) {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.redAccent),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  static ButtonStyle customBorderRadius({double radius = 8.0}) {
    return ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
