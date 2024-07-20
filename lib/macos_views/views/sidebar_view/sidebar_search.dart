import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';

class SidebarSearch extends StatefulWidget {
  const SidebarSearch({super.key});

  @override
  State<SidebarSearch> createState() => _SidebarSearchState();
}

class _SidebarSearchState extends State<SidebarSearch> {
  late final searchFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return MacosSearchField(
        placeholder: 'Search',
        controller: searchFieldController,
        onResultSelected: (result) {
          searchFieldController.clear();
        },
        results: dataState.addressList
            .map(
              (a) => SearchResultItem(
                UiService.getAccountName(a),
                onSelected: () => BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(a)),
              ),
            )
            .toList(),
      );
    });
  }
}
