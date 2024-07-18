import 'package:flutter/material.dart';

class TextFieldStyles {
  static inputDecoration(BuildContext context, String hintText, {double maxHeight = 55}) => InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 17, color: Theme.of(context).hintColor),
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).hoverColor,
        constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 55),
      );
}
