import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class AttachmentCard extends StatefulWidget {
  final AttachmentData attachment;
  final bool isFirst;
  final bool isLast;
  const AttachmentCard({super.key, required this.attachment, required this.isFirst, required this.isLast});

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
      await file.writeAsBytes(attachmentBytes);
      await OpenFile.open(filePath);
      setState(() => isDownloading = false);
    } catch (e) {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Text subTitle = Text(ByteConverterService.fromKiloBytes(widget.attachment.size.toDouble()).toHumanReadable(SizeUnit.mb));
    return BlocBuilder<DataBloc, DataState>(
      builder: (dataBlocContext, dataState) {
        if (Platform.isAndroid) {
          return CardListTile(
            isFirst: widget.isFirst,
            isLast: widget.isLast,
            child: ListTile(
              title: Text(widget.attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: subTitle,
              onTap: () => _downloadFile(dataState.selectedAddress!.authenticatedUser),
              trailing: isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
            ),
          );
        } else if (Platform.isWindows) {
          return CardListTile(
            isFirst: widget.isFirst,
            isLast: widget.isLast,
            child: fluent_ui.ListTile(
              title: Text(
                widget.attachment.filename,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: fluent_ui.FluentTheme.of(context).typography.body,
              ),
              subtitle: subTitle,
              onPressed: () => _downloadFile(dataState.selectedAddress!.authenticatedUser),
              trailing: isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
            ),
          );
        }
        return CardListTile(
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          child: ListTile(
            title: Text(widget.attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: subTitle,
            onTap: () => _downloadFile(dataState.selectedAddress!.authenticatedUser),
            trailing: isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
          ),
        );
      },
    );
  }
}
