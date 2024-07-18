import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/custom_alert_dialog.dart';
import 'package:tempbox/shared/styles/button.dart';
import 'package:tempbox/shared/styles/textfield.dart';

class AlertService {
  static Future<T?> showAlert<T>({
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

  static Future<T?> showAlertCustomContent<T>({
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

  static Future<T?> showAttributeDataOverlay<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool enableDrag = true,
    bool useSafeArea = false,
  }) async {
    return await OverlayService.showOverLay<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      clipBehavior: Clip.hardEdge,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
      builder: builder,
    );
  }

  static Future<T?> showPrompt<T>({
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
}
