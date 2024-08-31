import 'dart:async';

import 'package:flutter/cupertino.dart';

const double _kLeadingSize = 28.0;
const double _kMinHeight = _kLeadingSize + 2;
const double _kMinHeightWithSubtitle = _kLeadingSize + 2 * 10.0;
const EdgeInsetsDirectional _kPadding = EdgeInsetsDirectional.only(start: 10.0, end: 10.0);
const EdgeInsetsDirectional _kPaddingWithSubtitle = EdgeInsetsDirectional.only(start: 20.0, end: 14.0);
const double _kLeadingToTitle = 16.0;
const double _kNotchedTitleToSubtitle = 3.0;
const double _kAdditionalInfoToTrailing = 6.0;
const double _kNotchedTitleWithSubtitleFontSize = 16.0;
const double _kSubtitleFontSize = 12.0;

class CustomCupertinoListTile extends StatefulWidget {
  const CustomCupertinoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.additionalInfo,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.backgroundColorActivated,
    this.padding,
    this.leadingSize = _kLeadingSize,
    this.leadingToTitle = _kLeadingToTitle,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? additionalInfo;
  final Widget? leading;
  final Widget? trailing;
  final FutureOr<void> Function()? onTap;
  final Color? backgroundColor;
  final Color? backgroundColorActivated;
  final EdgeInsetsGeometry? padding;
  final double leadingSize;
  final double leadingToTitle;

  @override
  State<CustomCupertinoListTile> createState() => _CustomCupertinoListTileState();
}

class _CustomCupertinoListTileState extends State<CustomCupertinoListTile> {
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle = widget.subtitle == null
        ? CupertinoTheme.of(context).textTheme.textStyle
        : CupertinoTheme.of(context).textTheme.textStyle.merge(
              TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: widget.leading == null ? _kNotchedTitleWithSubtitleFontSize : null,
              ),
            );

    final TextStyle subtitleTextStyle = CupertinoTheme.of(context).textTheme.textStyle.merge(
          TextStyle(
            fontSize: _kSubtitleFontSize,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        );

    final TextStyle? additionalInfoTextStyle = widget.additionalInfo != null
        ? CupertinoTheme.of(context).textTheme.textStyle.merge(TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)))
        : null;

    final Widget title = DefaultTextStyle(
      style: titleTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: widget.title,
    );

    final EdgeInsetsGeometry padding = widget.padding ?? (widget.subtitle != null ? _kPaddingWithSubtitle : _kPadding);

    Widget? subtitle;
    if (widget.subtitle != null) {
      subtitle = DefaultTextStyle(
        style: subtitleTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: widget.subtitle!,
      );
    }

    Widget? additionalInfo;
    if (widget.additionalInfo != null) {
      additionalInfo = DefaultTextStyle(
        style: additionalInfoTextStyle!,
        maxLines: 1,
        child: widget.additionalInfo!,
      );
    }

    // The color for default state tile is set to either what user provided or
    // null and it will resolve to the correct color provided by context. But if
    // the tile was tapped, it is set to what user provided or if null to the
    // default color that matched the iOS-style.
    Color? backgroundColor = widget.backgroundColor;
    if (_tapped) {
      backgroundColor = widget.backgroundColorActivated ?? CupertinoColors.systemGrey4.resolveFrom(context);
    }

    final double minHeight = subtitle != null ? _kMinHeightWithSubtitle : _kMinHeight;

    final Widget child = Container(
      constraints: BoxConstraints(minWidth: double.infinity, minHeight: minHeight),
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            if (widget.leading != null) ...<Widget>[
              SizedBox(
                width: widget.leadingSize,
                height: widget.leadingSize,
                child: Center(
                  child: widget.leading,
                ),
              ),
              SizedBox(width: widget.leadingToTitle),
            ] else
              SizedBox(height: widget.leadingSize),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  title,
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: _kNotchedTitleToSubtitle),
                    subtitle,
                  ],
                ],
              ),
            ),
            if (additionalInfo != null) ...<Widget>[
              additionalInfo,
              if (widget.trailing != null) const SizedBox(width: _kAdditionalInfoToTrailing),
            ],
            if (widget.trailing != null) widget.trailing!
          ],
        ),
      ),
    );

    if (widget.onTap == null) {
      return child;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _tapped = true),
      onTapCancel: () => setState(() => _tapped = false),
      onTap: () async {
        await widget.onTap!();
        if (mounted) setState(() => _tapped = false);
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
