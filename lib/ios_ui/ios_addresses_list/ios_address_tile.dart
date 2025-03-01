import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/ios_address_info/ios_address_info.dart';
import 'package:tempbox/ios_ui/ios_messages_list/ios_messages_list.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';

class IosAddressTile extends StatelessWidget {
  final AddressData addressData;
  const IosAddressTile({super.key, required this.addressData});

  _openAddressInfoSheet(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    showCupertinoModalSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: IosAddressInfo(addressData: addressData),
      ),
    );
  }

  _navigateToMessagesList(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(addressData));
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const IosMessagesList(),
      ),
    ));
  }

  _deleteAddress(BuildContext context, BuildContext dataBlocContext, AddressData addressData) async {
    bool? choice = await AlertService.getConformation(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this address?',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(addressData));
    }
  }

  _removeAddress(BuildContext context, BuildContext dataBlocContext, AddressData addressData) async {
    bool? choice = await AlertService.getConformation(
      context: context,
      title: 'Alert',
      content:
          'Are you sure you want to remove this address?\nThis address will not be deleted, just removed from here.\nYou can bring it back from the removed addresses section.',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(RemoveAddressEvent(addressData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Slidable(
        groupTag: 'AddressItem',
        key: ValueKey(addressData.authenticatedUser.account.id),
        startActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(
            confirmDismiss: () async {
              _openAddressInfoSheet(context, dataBlocContext, addressData);
              return false;
            },
            onDismissed: () {},
            closeOnCancel: true,
            dismissThreshold: 0.5,
          ),
          children: [
            CupertinoTheme(
              data: CupertinoTheme.of(context).copyWith(primaryColor: CupertinoColors.white),
              child: SlidableAction(
                onPressed: (_) => _openAddressInfoSheet(context, dataBlocContext, addressData),
                backgroundColor: Colors.amber,
                // foregroundColor: Colors.white,
                icon: CupertinoIcons.info_circle_fill,
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.5,
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(
            confirmDismiss: () async {
              _deleteAddress(context, dataBlocContext, addressData);
              return false;
            },
            onDismissed: () {},
            closeOnCancel: true,
            dismissThreshold: 0.5,
          ),
          children: [
            CupertinoTheme(
              data: CupertinoTheme.of(context).copyWith(primaryColor: CupertinoColors.white),
              child: SlidableAction(
                onPressed: (_) => _removeAddress(context, dataBlocContext, addressData),
                backgroundColor: CupertinoColors.systemIndigo,
                // foregroundColor: Colors.white,
                icon: CupertinoIcons.clear_circled,
              ),
            ),
            CupertinoTheme(
              data: CupertinoTheme.of(context).copyWith(primaryColor: CupertinoColors.white),
              child: SlidableAction(
                onPressed: (_) => _deleteAddress(context, dataBlocContext, addressData),
                backgroundColor: CupertinoColors.systemRed,
                // foregroundColor: Colors.white,
                icon: CupertinoIcons.trash_fill,
              ),
            ),
          ],
        ),
        child: CupertinoListTile(
          title: Text(UiService.getAccountName(addressData)),
          leading: const Icon(CupertinoIcons.tray),
          trailing: const CupertinoListTileChevron(),
          additionalInfo: Text((dataState.accountIdToMessagesMap[addressData.authenticatedUser.account.id]?.length ?? '').toString()),
          onTap: () => _navigateToMessagesList(context, dataBlocContext, addressData),
        ),
      );
    });
  }
}
