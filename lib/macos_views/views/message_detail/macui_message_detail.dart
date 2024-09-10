import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/shared/components/attachment_card.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MacuiMessageDetail extends StatelessWidget {
  const MacuiMessageDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) {
        if (previous.selectedMessage?.id != current.selectedMessage?.id || previous.selectedMessage?.html != current.selectedMessage?.html) {
          return true;
        }
        return false;
      },
      builder: (dataBlocContext, dataState) {
        if (dataState.selectedAddress == null) {
          return const Center(child: Text('No Address Selected'));
        }
        if (dataState.selectedMessage == null) {
          return const Center(child: Text('No Message Selected'));
        }
        MessageData messageWithHtml = dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
        return ListView(
          children: [
            RenderMessage(key: Key(messageWithHtml.id), message: messageWithHtml),
            if (messageWithHtml.hasAttachments)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: messageWithHtml.attachments.length,
                  itemBuilder: (context, index) {
                    return AttachmentCard(key: Key(messageWithHtml.attachments[index].id), attachment: messageWithHtml.attachments[index]);
                  },
                ),
              )
          ],
        );
      },
    );
  }
}
