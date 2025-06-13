import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/android_views/message_detail/attachment_list.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MessageDetail extends StatelessWidget {
  final MessageData message;
  const MessageDetail({super.key, required this.message});

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
        MessageData messageWithHtml = dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
        List<IconButton> actions = [
          IconButton(
            onPressed: () async {
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
            icon: const Icon(Icons.share),
          ),
        ];
        if (messageWithHtml.hasAttachments) {
          actions.insert(
            0,
            IconButton(
              onPressed: () async {
                OverlayService.showOverLay(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  clipBehavior: Clip.hardEdge,
                  enableDrag: true,
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<DataBloc>(dataBlocContext),
                    child: AttachmentsList(messageData: messageWithHtml),
                  ),
                );
              },
              icon: const Icon(Icons.attachment_rounded),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(UiService.getMessageFromName(message)), actions: dataState.selectedMessage == null ? null : actions),
          body: RenderMessage(message: messageWithHtml),
        );
      },
    );
  }
}
