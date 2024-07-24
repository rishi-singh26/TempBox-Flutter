import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/android_views/messages_list/message_tile.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

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
                SliverAppBar.large(title: Text(UiService.getAccountName(dataState.selectedAddress!))),
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
      List<Message>? messages = dataState.accountIdToAddressesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null) {
        return const SliverToBoxAdapter(child: Center(child: Text('Inbox empty')));
      }
      return SliverList.separated(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          Message message = messages[index];
          return MessageTile(message: message, selectedAddress: dataState.selectedAddress!);
        },
        separatorBuilder: (context, index) => const Divider(indent: 20, height: 1),
      );
    });
  }
}
