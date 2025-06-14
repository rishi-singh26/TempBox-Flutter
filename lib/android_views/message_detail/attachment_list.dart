import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tempbox/models/attachment_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/shared/components/attachment_card.dart';

class AttachmentsList extends StatefulWidget {
  final MessageData messageData;
  final AuthenticatedUser authenticatedUser;
  const AttachmentsList({super.key, required this.messageData, required this.authenticatedUser});

  @override
  State<AttachmentsList> createState() => _AttachmentsListState();
}

class _AttachmentsListState extends State<AttachmentsList> {
  Map<String, bool> isDownloadingTracker = {}; // attachmentId: status
  Map<String, String> downloadedFilePaths = {}; // attachmentId: filePath in temp dir
  Map<String, String> fileDownloadErrors = {}; // attachmentId: error, error while downloading file
  Map<String, String> fileOpenErrors = {}; // attachmentId: error, error while opening file

  @override
  void initState() {
    super.initState();
    _downloadAttachments();
  }

  _downloadAttachments() async {
    List<Future<void>> downloadFutures = [];

    for (final attachment in widget.messageData.attachments) {
      // Mark as downloading
      isDownloadingTracker[attachment.id] = true;

      // Start download in parallel
      var downloadFuture = _downloadAttachment(attachment)
          .then((filePath) {
            setState(() {
              downloadedFilePaths[attachment.id] = filePath;
              isDownloadingTracker[attachment.id] = false;
            });
          })
          .catchError((e) {
            setState(() {
              fileDownloadErrors[attachment.id] = 'Error downloading ${attachment.filename}: $e';
              isDownloadingTracker[attachment.id] = false;
            });
          });

      downloadFutures.add(downloadFuture);
    }

    // Wait for all to finish
    await Future.wait(downloadFutures);
  }

  Future<String> _downloadAttachment(AttachmentData attachment) async {
    List<int> attachmentBytes = await widget.authenticatedUser.downloadAttachment(attachment.downloadUrl);

    Directory appTempDir = await getTemporaryDirectory();
    String filePath = '${appTempDir.path}/${attachment.filename}';
    File file = File(filePath);
    await file.writeAsBytes(attachmentBytes);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isVertical = constraints.maxHeight > constraints.maxWidth;
          if (widget.messageData.attachments.isEmpty) {
            return CustomScrollView(slivers: [SliverAppBar.large(title: const Text('Attachments'))]);
          }
          return CustomScrollView(
            slivers: [
              if (isVertical) SliverAppBar.large(title: Text("Attachments")),
              if (!isVertical) SliverAppBar(title: Text("Attachments"), pinned: true),
              SliverList.builder(
                itemCount: widget.messageData.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = widget.messageData.attachments[index];
                  return AttachmentCard(
                    key: Key(attachment.id),
                    attachment: attachment,
                    attachmentFilePath: downloadedFilePaths[attachment.id],
                    downloadError: fileDownloadErrors[attachment.id],
                    isDownloading: isDownloadingTracker[attachment.id] ?? false,
                    isFirst: index == 0,
                    isLast: index == widget.messageData.attachments.length - 1,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
