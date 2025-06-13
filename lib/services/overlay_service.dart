import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter/material.dart';

class OverlayService {
  static Future<T?> showOverLay<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) async {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide > 600;
    if (isTablet) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              clipBehavior: Clip.hardEdge,
              constraints: BoxConstraints(maxWidth: 700, maxHeight: size.height - 200),
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), color: Theme.of(context).scaffoldBackgroundColor),
              child: Builder(builder: builder),
            ),
          );
        },
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        transitionAnimationController: transitionAnimationController,
        anchorPoint: anchorPoint,
        useSafeArea: useSafeArea,
        barrierColor: barrierColor,
        useRootNavigator: useRootNavigator,
      );
    }
  }
}
