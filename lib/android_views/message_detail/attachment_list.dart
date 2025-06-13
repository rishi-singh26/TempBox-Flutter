import 'package:flutter/material.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/shared/components/attachment_card.dart';

class AttachmentsList extends StatefulWidget {
  final MessageData messageData;
  const AttachmentsList({super.key, required this.messageData});

  @override
  State<AttachmentsList> createState() => _AttachmentsListState();
}

class _AttachmentsListState extends State<AttachmentsList> {
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
                  return AttachmentCard(
                    key: Key(widget.messageData.attachments[index].id),
                    attachment: widget.messageData.attachments[index],
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
