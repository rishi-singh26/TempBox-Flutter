import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:tempbox/android_views/message_detail/message_detail.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({super.key, required this.message, required this.selectedAddress});

  final MessageData message;
  final AddressData selectedAddress;

  _navigateToMessagesDetail(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectMessageEvent(message: message, addressData: addressData));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<DataBloc>(dataBlocContext),
          child: MessageDetail(message: message),
        ),
      ),
    );
  }

  _deleteMessage(BuildContext context, BuildContext dataBlocContext, AddressData address) async {
    bool? choice = await AlertService.getConformation(context: context, title: 'Alert', content: 'Are you sure you want to delete this message?');
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteMessageEvent(message: message, addressData: address));
    }
  }

  _toggleMessageReadStatus(BuildContext dataBlocContext, AddressData selectedAddress) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(addressData: selectedAddress, message: message));
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
            extentRatio: 0.5,
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(
              confirmDismiss: () async {
                _toggleMessageReadStatus(dataBlocContext, dataState.selectedAddress!);
                return false;
              },
              onDismissed: () {},
              closeOnCancel: true,
              dismissThreshold: 0.5,
            ),
            children: [
              SlidableAction(
                onPressed: (_) => _toggleMessageReadStatus(dataBlocContext, dataState.selectedAddress!),
                backgroundColor: const Color(0XFF0B84FF),
                foregroundColor: Colors.white,
                icon: message.seen ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                label: message.seen ? "Unread" : "Read",
              ),
              SlidableAction(
                onPressed: dataState.selectedMessage == null
                    ? null
                    : (_) async {
                        if (dataState.selectedAddress == null || dataState.selectedMessage == null) return;
                        MessageSource? messageSource = await HttpService.getMessageSource(
                          dataState.selectedAddress!.authenticatedUser.token,
                          dataState.selectedMessage!.id,
                        );
                        if (messageSource == null) return;
                        SharePlus.instance.share(
                          ShareParams(
                            files: [XFile.fromData(utf8.encode(messageSource.data), mimeType: 'message/rfc822')],
                            fileNameOverrides: ['${dataState.selectedMessage!.subject}.eml'],
                          ),
                        );
                      },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: "Share",
              ),
            ],
          ),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(
              confirmDismiss: () async {
                _deleteMessage(context, dataBlocContext, dataState.selectedAddress!);
                return false;
              },
              onDismissed: () {},
              closeOnCancel: true,
              dismissThreshold: 0.5,
            ),
            children: [
              SlidableAction(
                onPressed: (_) => _deleteMessage(context, dataBlocContext, dataState.selectedAddress!),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: "Delete",
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
                    Text(UiService.getMessageFromName(message), style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(UiService.formatTimeTo12Hour(message.createdAt), style: Theme.of(context).textTheme.labelLarge),
                    hGap(5),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(message.subject), if (message.hasAttachments) const Icon(Icons.attachment_rounded, size: 19)],
            ),
            onTap: () => _navigateToMessagesDetail(context, dataBlocContext, dataState.selectedAddress!),
          ),
        );
      },
    );
  }
}
