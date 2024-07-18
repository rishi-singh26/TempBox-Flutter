import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:tempbox/views/message_detail/message_detail.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.selectedAddress,
  });

  final Message message;
  final AddressData selectedAddress;

  _navigateToMessagesDetail(BuildContext context, BuildContext dataBlocContext) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectMessageEvent(message));
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const MessageDetail(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    SizedBox hGap(double size) => SizedBox(width: size);
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        return Slidable(
          groupTag: 'MessageItem',
          key: ValueKey(message.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  message.seen
                      ? selectedAddress.authenticatedUser.unreadMessage(message.id)
                      : selectedAddress.authenticatedUser.readMessage(message.id);
                },
                backgroundColor: const Color(0XFF0B84FF),
                foregroundColor: Colors.white,
                icon: message.seen ? CupertinoIcons.envelope_badge_fill : CupertinoIcons.envelope_open_fill,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(onDismissed: () {}),
            children: [
              SlidableAction(
                onPressed: (con) {
                  selectedAddress.authenticatedUser.deleteMessage(message.id);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: CupertinoIcons.trash_fill,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 22, right: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!message.seen) const BlankBadge(),
                    if (!message.seen) hGap(10),
                    Text(
                      message.from['name'] ?? message.subject.substring(0, 30),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      UiService.formatTimeTo12Hour(message.createdAt),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    hGap(5),
                    const Icon(CupertinoIcons.chevron_right, size: 15),
                  ],
                )
              ],
            ),
            subtitle: Text(message.subject),
            onTap: () => _navigateToMessagesDetail(context, dataBlocContext),
          ),
        );
      },
    );
  }
}
