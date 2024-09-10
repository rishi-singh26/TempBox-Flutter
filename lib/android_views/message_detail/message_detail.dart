import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/attachment_card.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MessageDetail extends StatelessWidget {
  final MessageData message;
  const MessageDetail({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedMessage == null) {
        return Scaffold(
          appBar: AppBar(title: Text(UiService.getMessageFromName(message))),
          body: const SizedBox.shrink(),
        );
      }
      MessageData messageWithHtml = dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
      return Scaffold(
        appBar: AppBar(
          title: Text(UiService.getMessageFromName(message)),
          actions: [
            IconButton(
              onPressed: dataState.selectedMessage == null
                  ? null
                  : () async {
                      if (dataState.selectedAddress == null || dataState.selectedMessage == null) return;
                      MessageSource? messageSource = await HttpService.getMessageSource(
                        dataState.selectedAddress!.authenticatedUser.token,
                        dataState.selectedMessage!.id,
                      );
                      if (messageSource == null) return;
                      Share.shareXFiles(
                        [XFile.fromData(utf8.encode(messageSource.data), mimeType: 'message/rfc822')],
                        fileNameOverrides: ['${dataState.selectedMessage!.subject}.eml'],
                      );
                    },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            RenderMessage(message: messageWithHtml),
            if (messageWithHtml.hasAttachments)
              SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: messageWithHtml.attachments.length,
                  itemBuilder: (context, index) {
                    return AttachmentCard(key: Key(messageWithHtml.attachments[index].id), attachment: messageWithHtml.attachments[index]);
                  },
                ),
              )
          ],
        ),
      );
    });
  }
}
