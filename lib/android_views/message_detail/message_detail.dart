import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/padded_card.dart';
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
                  itemBuilder: (context, index) => AttachmentCard(attachment: messageWithHtml.attachments[index]),
                ),
              )
          ],
        ),
        floatingActionButton:
            messageWithHtml.hasAttachments ? FloatingActionButton(onPressed: () {}, child: const Icon(Icons.attach_file_rounded)) : null,
      );
    });
  }
}

class AttachmentCard extends StatefulWidget {
  final AttachmentData attachment;
  const AttachmentCard({super.key, required this.attachment});

  @override
  State<AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> {
  bool isDownloading = false;

  _downloadFile(AuthenticatedUser authenticatedUser) async {
    try {
      setState(() => isDownloading = true);
      List<int> attachmentBytes = await authenticatedUser.downloadAttachment(widget.attachment.downloadUrl);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/${widget.attachment.filename}';
      File file = File(filePath);
      file.writeAsBytes(attachmentBytes);
      await OpenFile.open(filePath);
      setState(() => isDownloading = false);
    } catch (e) {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return SizedBox(
        width: 300,
        child: PaddedCard(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: ListTile(
            title: Text(widget.attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(ByteConverterService.fromKiloBytes(widget.attachment.size.toDouble()).toHumanReadable(SizeUnit.kb)),
            onTap: () => _downloadFile(dataState.selectedAddress!.authenticatedUser),
            trailing: isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
          ),
        ),
      );
    });
  }
}
