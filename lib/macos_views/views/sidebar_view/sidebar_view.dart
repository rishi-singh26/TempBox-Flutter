import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart' hide MacosPulldownButton, MacosPulldownMenuItem;
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macui_address_info.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/custom_pulldown_button.dart';

class SidebarView extends StatelessWidget {
  final ScrollController scrollController;
  const SidebarView({super.key, required this.scrollController});

  _getSelectedIndex(AddressData? selected, List<AddressData> addresses) {
    if (addresses.isEmpty || selected == null) {
      return 0;
    }
    int index = addresses.indexWhere((a) => a.authenticatedUser.account.id == selected.authenticatedUser.account.id);
    return index >= 0 ? index : 0;
  }

  _refreshInbox(BuildContext dataBlocContext, AddressData? address) {
    if (address == null) {
      return;
    }
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  _showAddressInfo(BuildContext dataBlocContext, AddressData? address, BuildContext context) async {
    if (address == null) {
      return;
    }
    await Future.delayed(
      const Duration(milliseconds: 50),
      () => showMacosSheet(
        context: context,
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<DataBloc>(dataBlocContext),
          child: MacuiAddressInfo(addressData: address),
        ),
      ),
    );
  }

  _removeAddress(BuildContext dataBlocContext, AddressData? address, BuildContext context) async {
    if (address == null) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50), () async {
      final choice = await AlertService.getConformation<bool>(
        context: context,
        title: 'Alert',
        content:
            'Are you sure you want to remove this address?\nThis address will not be deleted, just removed from the list here.\nYou can bring it back from the removed addresses section.',
      );
      if (choice == true && dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(RemoveAddressEvent(address));
      }
    });
  }

  _deleteAddress(BuildContext dataBlocContext, AddressData? address, BuildContext context) async {
    if (address == null) {
      return;
    }
    await Future.delayed(
      const Duration(milliseconds: 50),
      () async {
        final choice = await AlertService.getConformation<bool>(
          context: context,
          title: 'Alert',
          content: 'Are you sure you want to delete this address?',
        );
        if (choice == true && dataBlocContext.mounted) {
          BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(address));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      List<SidebarItem> addresses = [];
      addToList(AddressData a) => addresses.add(SidebarItem(
            leading: const MacosIcon(CupertinoIcons.tray, size: 15),
            label: Text(
              UiService.getAccountName(a, shortName: true),
              style: MacosTheme.of(context).typography.body,
            ),
            trailing: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text((dataState.accountIdToMessagesMap[a.authenticatedUser.account.id]?.length ?? 0).toString()),
                const SizedBox(width: 5),
                CustomMacosPulldownButton(
                  icon: CupertinoIcons.ellipsis_circle,
                  items: [
                    MacosPulldownMenuItem(
                      title: const Text('Refresh Inbox'),
                      onTap: dataState.selectedAddress == null || dataState.selectedAddress?.archived == true
                          ? null
                          : () => _refreshInbox(dataBlocContext, dataState.selectedAddress),
                    ),
                    MacosPulldownMenuItem(
                      title: const Text('Address Info'),
                      onTap: dataState.selectedAddress == null ? null : () => _showAddressInfo(dataBlocContext, dataState.selectedAddress, context),
                    ),
                    MacosPulldownMenuItem(
                      title: const Text('Remove Address'),
                      onTap: dataState.selectedAddress == null ? null : () => _removeAddress(dataBlocContext, dataState.selectedAddress, context),
                    ),
                    MacosPulldownMenuItem(
                      title: const Text('Delete Address'),
                      onTap: dataState.selectedAddress == null ? null : () => _deleteAddress(dataBlocContext, dataState.selectedAddress, context),
                    ),
                  ],
                ),
              ],
            ),
          ));
      dataState.addressList.forEach(addToList);
      return SidebarItems(
        currentIndex: _getSelectedIndex(dataState.selectedAddress, dataState.addressList),
        onChanged: (i) {
          BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(dataState.addressList[i]));
        },
        scrollController: scrollController,
        items: addresses,
      );
    });
  }
}
