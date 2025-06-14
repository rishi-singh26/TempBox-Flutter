import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class AttachmentCard extends StatelessWidget {
  final AttachmentData attachment;
  final bool isFirst;
  final bool isLast;
  final bool isDownloading;
  final String? attachmentFilePath;
  final String? downloadError;
  const AttachmentCard({
    super.key,
    required this.attachment,
    required this.isFirst,
    required this.isLast,
    required this.isDownloading,
    required this.attachmentFilePath,
    required this.downloadError,
  });

  _openFile() async {
    if (attachmentFilePath != null) {
      OpenResult res = await OpenFile.open(attachmentFilePath);
      if (res.type != ResultType.done) {}
    }
  }

  _shareFile() async {
    if (attachmentFilePath != null) {
      final file = File(attachmentFilePath!);
      Uint8List bytes = await file.readAsBytes();
      SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: attachment.contentType)],
          fileNameOverrides: [attachment.filename],
        ),
      );
    }
  }

  Widget? _trailingWidget() {
    if (isDownloading) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator());
    } else if (attachmentFilePath != null) {
      return IconButton(icon: Icon(Icons.share), onPressed: _shareFile);
    } else if (downloadError != null) {
      return Icon(CupertinoIcons.exclamationmark_triangle_fill);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Text subTitle = Text(ByteConverterService.fromKiloBytes(attachment.size.toDouble()).toHumanReadable(SizeUnit.mb));
    return BlocBuilder<DataBloc, DataState>(
      builder: (dataBlocContext, dataState) {
        if (Platform.isAndroid) {
          return CardListTile(
            isFirst: isFirst,
            isLast: isLast,
            child: ListTile(
              title: Text(attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: subTitle,
              onTap: _openFile,
              trailing: _trailingWidget(),
            ),
          );
        } else if (Platform.isWindows) {
          return CardListTile(
            isFirst: isFirst,
            isLast: isLast,
            child: fluent_ui.ListTile(
              title: Text(
                attachment.filename,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: fluent_ui.FluentTheme.of(context).typography.body,
              ),
              subtitle: subTitle,
              onPressed: _openFile,
              trailing: _trailingWidget(),
            ),
          );
        }
        return CardListTile(
          isFirst: isFirst,
          isLast: isLast,
          child: ListTile(
            title: Text(attachment.filename, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: subTitle,
            onTap: _openFile,
            trailing: _trailingWidget(),
          ),
        );
      },
    );
  }
}
