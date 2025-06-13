import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/shared/components/attachment_card.dart';
import 'package:tempbox/shared/components/render_message.dart';
import 'package:tempbox/win_views/views/selected_address_view/winui_messages_list.dart';

class WinuiSelectedAddressView extends StatelessWidget {
  final menuController = FlyoutController();
  WinuiSelectedAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      builder: (dataBlocContext, dataState) {
        return Row(
          children: [
            SizedBox(
              width: 280,
              child: Builder(
                builder: (context) {
                  if (dataState.selectedAddress == null) {
                    return const Center(child: Text('No Address Selected'));
                  }
                  return ScaffoldPage(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    content: Builder(
                      builder: (context) {
                        if (dataState.selectedAddress == null) {
                          return const Center(child: Text('No Address Selected'));
                        }
                        return const WinuiMessagesList();
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(direction: Axis.vertical),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (dataState.selectedAddress == null) {
                    return const Center(child: Text(''));
                  }
                  if (dataState.selectedMessage == null) {
                    return const Center(child: Text(''));
                  }
                  MessageData messageWithHtml = dataState.messageIdToMessageMap[dataState.selectedMessage!.id] ?? dataState.selectedMessage!;
                  return ScaffoldPage(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    content: ListView(
                      children: [
                        RenderMessage(key: Key(messageWithHtml.id), message: messageWithHtml),
                        if (messageWithHtml.hasAttachments)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: messageWithHtml.attachments.length,
                              itemBuilder: (context, index) {
                                return AttachmentCard(
                                  key: Key(messageWithHtml.attachments[index].id),
                                  attachment: messageWithHtml.attachments[index],
                                  isFirst: index == 0,
                                  isLast: index == messageWithHtml.attachments.length - 1,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
