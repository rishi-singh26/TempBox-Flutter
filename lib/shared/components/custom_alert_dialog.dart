import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final EdgeInsets? contentPadding;
  final List<Widget> actions;
  const CustomAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.contentPadding,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: contentPadding ?? const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            const SizedBox(height: 6),
            if (content != null) content!,
            const SizedBox(height: 15),
            ...actions,
          ],
        ),
      ),
    );
  }
}
