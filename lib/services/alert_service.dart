import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/styles/textfield.dart';

class AlertService {
  // Alert setup START

  static Future<T?> showAlert<T>({required BuildContext context, required String title, required String content}) async {
    if (Platform.isWindows || Platform.isLinux) {
      return await _showAlertWindowsAndLinux(context, title, content);
    } else {
      return await _showAlertAndroid(context, title, content);
    }
  }

  static Future<T?> _showAlertAndroid<T>(BuildContext context, String title, String content) async {
    return await OverlayService.showOverLay<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [FilledButton.tonal(onPressed: () => Navigator.pop(context), child: const Text('Ok'))],
        );
      },
    );
  }

  static Future<T?> _showAlertWindowsAndLinux<T>(BuildContext context, String title, String content) async {
    return await fluent_ui.showDialog<T>(
      context: context,
      builder: (context) => fluent_ui.ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [fluent_ui.FilledButton(child: const Text('Ok'), onPressed: () => Navigator.of(context).pop(true))],
      ),
    );
  }
  // Alert setup END

  // Confirmation setup START
  static Future<T?> getConformation<T>({
    required BuildContext context,
    required String title,
    required String content,
    String confirmBtnTxt = 'Yes',
    String secondaryBtnTxt = 'Cancel',
    bool truncateContent = false,
    int truncateContentLength = 100,
    bool useDestructiveBtn = true, // when true the action button style is descrictive
    bool dismissable = false,
  }) async {
    if (Platform.isWindows || Platform.isLinux) {
      return await _getConfirmationWindowsAndLinux<T>(
        context: context,
        title: title,
        content: content,
        confirmBtnTxt: confirmBtnTxt,
        secondaryBtnTxt: secondaryBtnTxt,
        truncateContent: truncateContent,
        truncateContentLength: truncateContentLength,
      );
    } else {
      return _getConfirmationAndroid(
        context: context,
        title: title,
        content: content,
        confirmBtnTxt: confirmBtnTxt,
        secondaryBtnTxt: secondaryBtnTxt,
        truncateContent: truncateContent,
        truncateContentLength: truncateContentLength,
        dismissable: dismissable,
      );
    }
  }

  static Future<T?> _getConfirmationAndroid<T>({
    required BuildContext context,
    required String title,
    required String content,
    bool dismissable = false,
    String confirmBtnTxt = 'Yes',
    String secondaryBtnTxt = 'Cancel',
    bool truncateContent = false,
    int truncateContentLength = 100,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissable, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            truncateContent && content.length >= truncateContentLength ? '${content.substring(0, truncateContentLength - 1)}...' : content,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop(true) : null, child: Text(confirmBtnTxt)),
            TextButton(onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop(false) : null, child: Text(secondaryBtnTxt)),
          ],
        );
      },
    );
  }

  static Future<T?> _getConfirmationWindowsAndLinux<T>({
    required BuildContext context,
    required String title,
    required String content,
    String confirmBtnTxt = 'Yes',
    String secondaryBtnTxt = 'Cancel',
    bool truncateContent = false,
    int truncateContentLength = 100,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => fluent_ui.ContentDialog(
        title: Text(title),
        content: Text(
          truncateContent ? '${content.substring(0, truncateContentLength - 1)}...' : content,
          style: fluent_ui.FluentTheme.of(context).typography.caption,
        ),
        actions: [
          fluent_ui.Button(child: Text(confirmBtnTxt), onPressed: () => Navigator.of(context).pop(true)),
          fluent_ui.FilledButton(child: Text(secondaryBtnTxt), onPressed: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
  // Confirmation setup End

  // Snackbar setup START
  static Future<void> showSnackBar(BuildContext context, String title, String content) async {
    if (Platform.isAndroid) {
      _showAndroidSnackBar(context, title, content);
    } else if (Platform.isWindows) {
      await _showWindowsSnackBar(context, title, content);
    } else {
      await showAlert<void>(context: context, title: title, content: content);
    }
  }

  static Future<void> _showWindowsSnackBar(BuildContext context, String title, String content) async {
    await fluent_ui.displayInfoBar(
      context,
      builder: (context, close) {
        return fluent_ui.InfoBar(
          title: Text(title),
          content: Text(content),
          action: fluent_ui.IconButton(icon: const Icon(fluent_ui.FluentIcons.clear), onPressed: close),
          severity: fluent_ui.InfoBarSeverity.error,
        );
      },
    );
  }

  static void _showAndroidSnackBar(BuildContext context, String title, String content) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(label: 'Close', onPressed: () {}),
        content: const Text('Awesome SnackBar!'),
        duration: const Duration(milliseconds: 1500),
        width: 280.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  // Snackbar setup END

  static Future<T?> showPromptAndroid<T>({
    required BuildContext context,
    required String title,
    String? placeholder,
    String? primaryButtonLabel,
    TextInputType? textInputType,
    List<TextInputFormatter>? textFormatters,
    double value = 0.0,
  }) async {
    TextEditingController controller = TextEditingController(text: value.toStringAsFixed(2));
    return await OverlayService.showOverLay<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: TextFieldStyles.inputDecoration(context, placeholder ?? 'Enter Value'),
            keyboardType: textInputType,
            inputFormatters: textFormatters,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop(controller.text) : null,
              child: Text(primaryButtonLabel ?? 'Done'),
            ),
            FilledButton.tonal(onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : null, child: const Text('Cancel')),
          ],
        );
      },
    );
  }
}
