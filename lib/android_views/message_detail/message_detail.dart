import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/android_views/message_detail/attachment_list.dart';
import 'package:tempbox/android_views/message_detail/message_info.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MessageDetail extends StatelessWidget {
  final MessageData message;
  const MessageDetail({super.key, required this.message});

  _handleOptionTap(
    BuildContext context,
    BuildContext dataBlocContext,
    int value,
    AddressData? selectedAddress,
    MessageData selectedMessage,
  ) async {
    switch (value) {
      case 0:
        _showMessageInfo(context, dataBlocContext, selectedMessage);
        break;
      case 1:
        _shareEmail(selectedAddress, selectedMessage);
        break;
      default:
    }
  }

  _showMessageInfo(BuildContext context, BuildContext dataBlocContext, MessageData selectedMessage) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: AndroidMessageInfo(messageData: selectedMessage),
      ),
    );
  }

  _shareEmail(AddressData? selectedAddress, MessageData? selectedMessage) async {
    if (selectedAddress == null || selectedMessage == null) return;

    MessageSource? messageSource = await HttpService.getMessageSource(
      selectedAddress.authenticatedUser.token,
      selectedMessage.id,
    );

    if (messageSource == null) return;

    SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(messageSource.data), mimeType: 'message/rfc822')],
        fileNameOverrides: ['${selectedMessage.subject}.eml'],
      ),
    );
  }

  _showAttachments(BuildContext context, BuildContext dataBlocContext, MessageData message, AuthenticatedUser user) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: AttachmentsList(messageData: message, authenticatedUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      builder: (dataBlocContext, dataState) {
        if (dataState.selectedMessage == null) {
          return Scaffold(
            appBar: AppBar(title: Text(UiService.getMessageFromName(message))),
            body: const SizedBox(height: 10, width: 10),
          );
        }
        MessageData messageWithHtml =
            dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
        List<Widget> actions = [
          PopupMenuButton<int>(
            initialValue: null,
            onSelected: (int item) =>
                _handleOptionTap(context, dataBlocContext, item, dataState.selectedAddress, messageWithHtml),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                enabled: dataState.addressList.isNotEmpty,
                value: 0,
                child: const ListTile(leading: Icon(Icons.info_outline), title: Text('Info')),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: const ListTile(leading: Icon(Icons.share), title: Text('Share .eml file')),
              ),
            ],
          ),
        ];
        if (messageWithHtml.hasAttachments) {
          actions.insert(
            0,
            IconButton(
              onPressed: () =>
                  _showAttachments(context, dataBlocContext, messageWithHtml, dataState.selectedAddress!.authenticatedUser),
              icon: const Icon(Icons.attachment_rounded),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(UiService.getMessageFromName(dataState.selectedMessage!)),
            actions: dataState.selectedMessage == null ? null : actions,
          ),
          body: RenderMessage(message: messageWithHtml),
        );
      },
    );
  }
}
