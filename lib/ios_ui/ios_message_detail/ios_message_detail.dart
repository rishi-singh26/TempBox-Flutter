import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
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
                    height: 105,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: messageWithHtml.attachments.length,
                      itemBuilder: (context, index) => AttachmentCard(attachment: messageWithHtml.attachments[index]),
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
      return Container(
        width: 300,
        padding: const EdgeInsets.all(8),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
          child: CupertinoListTile(
            backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
            padding: const EdgeInsets.all(16),
            title: Text(widget.attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(ByteConverterService.fromKiloBytes(widget.attachment.size.toDouble()).toHumanReadable(SizeUnit.mb)),
            onTap: () => _downloadFile(dataState.selectedAddress!.authenticatedUser),
            trailing: isDownloading ? const CupertinoActivityIndicator() : null,
          ),
        ),
      );
    });
  }
}
