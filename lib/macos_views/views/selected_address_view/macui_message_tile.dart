import 'package:flutter/cupertino.dart';

class MacuiMessageTile extends StatefulWidget {
  const MacuiMessageTile({
    super.key,
    required this.selectedIndex,
    required this.index,
    required this.select,
    required this.child,
    this.selectedColor = const Color.fromRGBO(42, 98, 217, 1.0),
  });

  final int selectedIndex;
  final int index;
  final void Function() select;
  final Color selectedColor;
  final Widget child;

  @override
  State<MacuiMessageTile> createState() => _MacuiMessageTileState();
}

class _MacuiMessageTileState extends State<MacuiMessageTile> {
  final GlobalKey _globalKey = GlobalKey();

  bool get _isSelected => widget.index == widget.selectedIndex;

  Color _getBackgroundColor({required bool isIndexOdd}) {
    if (_isSelected) return widget.selectedColor;
    if (isIndexOdd) return const Color.fromRGBO(128, 128, 128, 0.15);
    return const Color.fromRGBO(128, 128, 128, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.select(),
      child: Container(
        key: _globalKey,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: _getBackgroundColor(isIndexOdd: widget.index.isOdd)),
        child: widget.child,
      ),
    );
  }
}
