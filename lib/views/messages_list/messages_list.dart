import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/views/messages_list/message_tile.dart';

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
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(title: Text(UiService.getAccountName(dataState.selectedAddress!))),
              MessageList(selectedAddress: dataState.selectedAddress!),
            ],
          ),
        ),
      );
    });
  }
}

class MessageList extends StatefulWidget {
  final AddressData selectedAddress;
  const MessageList({super.key, required this.selectedAddress});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool loading = true;
  List<Message> messages = [];

  _getMessages() async {
    messages = await widget.selectedAddress.authenticatedUser.messagesAt(1);
    setState(() => loading = false);
  }

  @override
  void initState() {
    _getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverToBoxAdapter(child: CircularProgressIndicator.adaptive());
    }
    return SliverList.separated(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        Message message = messages[index];
        return MessageTile(message: message, selectedAddress: widget.selectedAddress);
      },
      separatorBuilder: (context, index) => const Divider(indent: 20, height: 1),
    );
  }
}
