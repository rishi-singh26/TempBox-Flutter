import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/custom_alert_dialog.dart';
import 'package:tempbox/shared/styles/button.dart';
import 'package:tempbox/shared/styles/textfield.dart';

class AlertService {
  static Future<T?> showAlert<T>({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    if (Platform.isMacOS) {
      return await showMacosAlertDialog<T>(
        context: context,
        builder: (context) => MacosAlertDialog(
          appIcon: const FlutterLogo(size: 64),
          title: Text(title),
          message: Text(content),
          //horizontalActions: false,
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: Navigator.of(context).pop,
            child: const Text('Ok'),
          ),
        ),
      );
    } else if (Platform.isWindows) {
      return await fluent_ui.showDialog<T>(
        context: context,
        builder: (context) => fluent_ui.ContentDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            fluent_ui.FilledButton(child: const Text('Ok'), onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      );
    } else if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(onPressed: Navigator.of(context).pop, child: const Text('Ok')),
          ],
        ),
      );
    } else {
      return await OverlayService.showOverLay<T>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (context) {
          return CustomAlertDialog(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(content),
            actions: [
              FilledButton.tonal(
                style: ButtonStyles.customBorderRadius(),
                onPressed: () => Navigator.pop(context),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<T?> showAlertCustomContentAndroid<T>({
    required BuildContext context,
    required Widget title,
    Widget? content,
    List<Widget> actions = const [],
    EdgeInsets? contentPadding,
    bool useSafeArea = false,
  }) async {
    return await OverlayService.showOverLay<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      builder: (context) {
        return CustomAlertDialog(title: title, content: content, actions: actions, contentPadding: contentPadding);
      },
    );
  }

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      showAlwaysAsDialog: true,
      builder: (context) {
        return CustomAlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: TextFieldStyles.inputDecoration(context, placeholder ?? 'Enter Value'),
            keyboardType: textInputType,
            inputFormatters: textFormatters,
          ),
          actions: [
            FilledButton(
              style: ButtonStyles.customBorderRadius(),
              onPressed: () {
                Navigator.of(context).canPop() ? Navigator.of(context).pop(controller.text) : null;
              },
              child: Text(primaryButtonLabel ?? 'Done'),
            ),
            FilledButton.tonal(
              style: ButtonStyles.customBorderRadius(),
              onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : null,
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<T?> getConformation<T>({
    required BuildContext context,
    required String title,
    required String content,
    String confirmBtnTxt = 'Yes',
    String secondaryBtnTxt = 'Cancel',
    bool truncateContent = false,
    int truncateContentLength = 100,
    bool useDestructiveBtn = true, // when true the action button style is descrictive
  }) async {
    if (Platform.isMacOS) {
      return await showMacosAlertDialog<T>(
        context: context,
        builder: (context) => MacosAlertDialog(
          appIcon: const FlutterLogo(size: 64),
          title: Text(title),
          message: Text(
            truncateContent && content.length > truncateContentLength ? '${content.substring(0, truncateContentLength - 1)}...' : content,
            textAlign: TextAlign.center,
            style: MacosTheme.of(context).typography.caption1,
          ),
          horizontalActions: false,
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmBtnTxt),
          ),
          secondaryButton: PushButton(
            controlSize: ControlSize.large,
            secondary: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(secondaryBtnTxt),
          ),
        ),
      );
    } else if (Platform.isWindows) {
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
            fluent_ui.FilledButton(
              child: Text(secondaryBtnTxt),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    } else if (Platform.isIOS) {
      return await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: useDestructiveBtn,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmBtnTxt),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(secondaryBtnTxt),
            ),
          ],
        ),
      );
    } else {
      return await OverlayService.showOverLay<T>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (context) {
          return CustomAlertDialog(
            title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            content: Text(
              truncateContent ? '${content.substring(0, truncateContentLength - 1)}...' : content,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            actions: [
              FilledButton(
                style: useDestructiveBtn ? ButtonStyles.destructive() : ButtonStyles.customBorderRadius(),
                onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop(true) : null,
                child: Text(confirmBtnTxt),
              ),
              FilledButton.tonal(
                style: ButtonStyles.customBorderRadius(),
                onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop(false) : null,
                child: Text(secondaryBtnTxt),
              ),
            ],
          );
        },
      );
    }
  }
}
