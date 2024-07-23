import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class SidebarView extends StatelessWidget {
  final ScrollController scrollController;
  const SidebarView({super.key, required this.scrollController});

  _getSelectedIndex(AddressData? selected, List<AddressData> addresses) {
    if (selected == null) {
      return 0;
    }
    int index = addresses.indexWhere((a) => a.authenticatedUser.account.id == selected.authenticatedUser.account.id);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
        return SidebarItems(
          currentIndex: _getSelectedIndex(dataState.selectedAddress, dataState.addressList),
          onChanged: (i) {
            BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(dataState.addressList[i]));
          },
          scrollController: scrollController,
          items: dataState.addressList
              .map((a) => SidebarItem(
                    leading: const MacosIcon(CupertinoIcons.tray, size: 15),
                    label: Text(
                      UiService.getAccountName(a),
                      style: MacosTheme.of(context).typography.body,
                    ),
                    trailing: Text((dataState.accountIdToAddressesMap[a.authenticatedUser.account.id]?.length ?? 0).toString()),
                  ))
              .toList(),
        );
      });
    });
  }
}
