import 'package:flutter/material.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class AndroidMessageInfo extends StatelessWidget {
  final MessageData messageData;

  const AndroidMessageInfo({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isVertical = constraints.maxHeight > constraints.maxWidth;
          return CustomScrollView(
            slivers: [
              if (isVertical) SliverAppBar.large(title: Text("Message Info")),
              if (!isVertical) SliverAppBar(title: Text("Message Info"), pinned: true),
              SliverList.list(
                children: [
                  CardListTile(
                    isFirst: true,
                    child: ListTile(title: Text('Sender Name: ${UiService.getMessageFromName(messageData)}')),
                  ),
                  CardListTile(child: ListTile(title: Text('Sender Email: ${messageData.from['address'] ?? ''}'))),
                  CardListTile(
                    child: ListTile(
                      title: TextButton(
                        onPressed: () => UiService.copyToClipboard(messageData.from['address'] ?? ''),
                        child: Text("Copy Sender Email"),
                      ),
                    ),
                  ),
                  CardListTile(
                    isLast: true,
                    child: ListTile(title: Text('Received At: ${UiService.formatTimeTo12Hour(messageData.createdAt)}')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
