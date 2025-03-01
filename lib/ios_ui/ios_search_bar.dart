import 'package:flutter/cupertino.dart';

class IosSearchBar extends StatefulWidget {
  final Function(String) onChange;
  const IosSearchBar({super.key, required this.onChange});

  @override
  State<IosSearchBar> createState() => _IosSearchBarState();
}

class _IosSearchBarState extends State<IosSearchBar> {
  bool isSearchFieldFocused = false;
  String _searchFieldText = "";
  final TextEditingController _searchFieldController = TextEditingController();
  final FocusNode _searchFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFieldFocusNode.addListener(() {
      setState(() => isSearchFieldFocused = _searchFieldFocusNode.hasFocus);
    });

    _searchFieldController.addListener(() {
      setState(() => _searchFieldText = _searchFieldController.text);
      widget.onChange(_searchFieldController.text);
    });
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: isSearchFieldFocused || _searchFieldText.isNotEmpty ? 65 : 0),
          child: CupertinoSearchTextField(
            focusNode: _searchFieldFocusNode,
            controller: _searchFieldController,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: isSearchFieldFocused || _searchFieldText.isNotEmpty ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              height: 30,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Cancel', style: theme.textTheme.actionTextStyle.copyWith(fontSize: 18)),
                onPressed: () {
                  _searchFieldFocusNode.unfocus();
                  _searchFieldController.text = "";
                  _searchFieldText = "";
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
