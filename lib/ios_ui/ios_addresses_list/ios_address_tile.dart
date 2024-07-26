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

  _toggleArchiveAddress(BuildContext context, BuildContext dataBlocContext, AddressData addressData) async {
    String alertMessage = 'Are you sure you want to ${addressData.archived ? 'unarchive' : 'archive'} this address?';
    bool? choice = await AlertService.getConformation(context: context, title: 'Alert', content: alertMessage);
    if (choice == true && dataBlocContext.mounted) {
      if (addressData.archived) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(UnarchiveAddressEvent(addressData));
        return;
      }
      BlocProvider.of<DataBloc>(dataBlocContext).add(ArchiveAddressEvent(addressData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Slidable(
        groupTag: 'AddressItem',
        key: ValueKey(addressData.authenticatedUser.account.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _openAddressInfoSheet(context, dataBlocContext, addressData),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.info_circle_fill,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _toggleArchiveAddress(context, dataBlocContext, addressData),
              backgroundColor: CupertinoColors.systemIndigo,
              foregroundColor: CupertinoColors.white,
              icon: addressData.archived ? CupertinoIcons.archivebox_fill : CupertinoIcons.archivebox,
            ),
            SlidableAction(
              onPressed: (_) => _deleteAddress(context, dataBlocContext, addressData),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.trash_fill,
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
