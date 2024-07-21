import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/custom_alert_dialog.dart';
import 'package:tempbox/shared/styles/button.dart';
import 'package:tempbox/shared/styles/textfield.dart';

class AlertService {
  static Future<T?> showAlertAndroid<T>({
    required BuildContext context,
    required String title,
    String? content,
    List<Widget> actions = const [],
  }) async {
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
          content: content == null ? null : Text(content),
          actions: actions,
        );
      },
    );
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

  static Future<T?> getConformationAndroid<T>({
    required BuildContext context,
    required String title,
    String? content,
    required void Function() onConfirmation,
    String confirmBtnTxt = 'Yes',
    bool useDestructiveBtn = true, // when true the action button style is descrictive
  }) async {
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: content == null ? null : Text(content),
          actions: [
            FilledButton(
              style: useDestructiveBtn ? ButtonStyles.destructive() : ButtonStyles.customBorderRadius(),
              onPressed: () {
                onConfirmation();
                Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
              },
              child: Text(confirmBtnTxt),
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

  static Future<T?> showAlertMacos<T>({
    required BuildContext context,
    required String title,
    required String content,
    List<Widget> actions = const [],
  }) async {
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
          child: const Text('Label'),
        ),
      ),
    );
  }

  static Future<T?> getConformationMacos<T>({
    required BuildContext context,
    required String title,
    required String content,
    String confirmBtnTxt = 'Yes',
  }) async {
    return await showMacosAlertDialog<T>(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const FlutterLogo(size: 64),
        title: Text(title),
        message: Text(content, textAlign: TextAlign.center),
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
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
