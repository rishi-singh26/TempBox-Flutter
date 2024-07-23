import 'package:flutter/material.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MessageDetail extends StatelessWidget {
  final Message message;
  const MessageDetail({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(UiService.getMessageFromName(message))),
      body: RenderMessage(message: message),
    );
  }
}
