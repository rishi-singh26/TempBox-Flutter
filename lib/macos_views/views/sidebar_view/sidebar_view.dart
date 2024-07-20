import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';

class SidebarView extends StatefulWidget {
  final ScrollController scrollController;
  const SidebarView({super.key, required this.scrollController});

  @override
  State<SidebarView> createState() => _SidebarViewState();
}

class _SidebarViewState extends State<SidebarView> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return SidebarItems(
        currentIndex: pageIndex,
        onChanged: (i) {
          setState(() => pageIndex = i);
          BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(dataState.addressList[i]));
        },
        scrollController: widget.scrollController,
        itemSize: SidebarItemSize.large,
        items: dataState.addressList
            .map((a) => SidebarItem(
                leading: const MacosIcon(CupertinoIcons.tray, size: 15),
                label: Text(
                  UiService.getAccountName(a),
                  style: MacosTheme.of(context).typography.body,
                )))
            .toList(),
      );
    });
  }
}
