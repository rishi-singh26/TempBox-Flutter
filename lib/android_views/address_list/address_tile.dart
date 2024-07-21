import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';
import 'package:tempbox/android_views/address_info/address_info.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/android_views/messages_list/messages_list.dart';

class AddressTile extends StatelessWidget {
  final int index;
  const AddressTile({super.key, required this.index});

  _openAddressInfoSheet(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: AddressInfo(addressData: addressData),
      ),
    );
  }

  _navigateToMessagesList(BuildContext context, BuildContext dataBlocContext, BuildContext messagesBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(addressData));
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: BlocProvider.value(
          value: BlocProvider.of<MessagesBloc>(messagesBlocContext),
          child: const MessagesList(),
        ),
      ),
    ));
  }

  _deleteAddress(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    AlertService.getConformationAndroid(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this address?',
      onConfirmation: () => BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(addressData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<MessagesBloc, MessagesState>(builder: (messagesBlocContext, messagesState) {
        AddressData addressData = dataState.addressList[index];
        return CardListTile(
          isFirst: index == 0,
          isLast: index == dataState.addressList.length - 1,
          child: Slidable(
            groupTag: 'AddressItem',
            key: ValueKey(addressData.authenticatedUser.account.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _openAddressInfoSheet(context, dataBlocContext, addressData),
                  backgroundColor: Colors.amber,
                  // backgroundColor: const Color(0XFFFED709),
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.info_circle_fill,
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(onDismissed: () => _deleteAddress(context, dataBlocContext, addressData)),
              children: [
                SlidableAction(
                  onPressed: (con) => _deleteAddress(con, dataBlocContext, addressData),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.trash_fill,
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(CupertinoIcons.tray, color: Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.red),
              title: Text(UiService.getAccountName(addressData)),
              trailing: const Icon(CupertinoIcons.chevron_right, size: 17),
              onTap: () => _navigateToMessagesList(context, dataBlocContext, messagesBlocContext, addressData),
            ),
          ),
        );
      });
    });
  }
}
