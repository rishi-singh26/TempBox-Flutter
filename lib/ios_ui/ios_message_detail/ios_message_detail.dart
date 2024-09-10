import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/padded_card.dart';
import 'package:tempbox/shared/components/render_message.dart';

class IosMessageDetail extends StatelessWidget {
  final MessageData message;
  const IosMessageDetail({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedMessage == null) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            middle: Text(UiService.getMessageFromName(message)),
            backgroundColor: AppColors.navBarColor,
          ),
          child: const SizedBox.shrink(),
        );
      }
      MessageData messageWithHtml = dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppColors.navBarColor,
          border: null,
          middle: Text(UiService.getMessageFromName(messageWithHtml)),
          previousPageTitle: dataState.selectedAddress!.addressName,
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
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
            child: const Icon(CupertinoIcons.share),
          ),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          bool isVertical = constraints.maxHeight > constraints.maxWidth;
          double horizontalPadding = isVertical ? 0 : 100;
          return Padding(
            padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 5),
            child: ListView(
              children: [
                RenderMessage(message: messageWithHtml),
                if (messageWithHtml.hasAttachments)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: messageWithHtml.attachments.length,
                      itemBuilder: (context, index) {
                        AttachmentData attachment = messageWithHtml.attachments[index];
                        return SizedBox(
                          width: 300,
                          child: PaddedCard(
                            child: ListTile(
                              title: Text(attachment.filename),
                              subtitle: Text(attachment.contentType),
                              onTap: () async {
                                List<int> attachmentBytes =
                                    await dataState.selectedAddress!.authenticatedUser.downloadAttachment(attachment.downloadUrl);
                                File file = File.fromRawPath(Uint8List.fromList(attachmentBytes));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
              ],
            ),
          );
        }),
      );
    });
  }
}
