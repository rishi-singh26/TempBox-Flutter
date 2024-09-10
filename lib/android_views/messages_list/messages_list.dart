import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/android_views/address_info/address_info.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/android_views/messages_list/message_tile.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null) {
        return Scaffold(appBar: AppBar(), body: const Center(child: Text('No Address Selected!')));
      }
      return Scaffold(
        body: SlidableAutoCloseBehavior(
          child: RefreshIndicator(
            edgeOffset: 60,
            onRefresh: () async {
              BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: dataState.selectedAddress!));
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text(UiService.getAccountName(dataState.selectedAddress!)),
                  actions: [
                    IconButton(
                      onPressed: () => _openAddressInfoSheet(context, dataBlocContext, dataState.selectedAddress!),
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                  ],
                ),
                const MessageList(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (context, dataState) {
      if (dataState.selectedAddress == null) {
        return const SliverToBoxAdapter(child: Center(child: Text('Address not selected')));
      }
      List<MessageData>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null) {
        return const SliverToBoxAdapter(child: Center(child: Text('Inbox empty')));
      }
      return SliverList.separated(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          MessageData message = messages[index];
          return MessageTile(message: message, selectedAddress: dataState.selectedAddress!);
        },
        separatorBuilder: (context, index) => const Divider(indent: 20, height: 1),
      );
    });
  }
}
