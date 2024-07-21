import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';
import 'package:tempbox/win_views/views/selected_address_view/winui_messages_list.dart';

class WinuiSelectedAddressView extends StatelessWidget {
  const WinuiSelectedAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<MessagesBloc, MessagesState>(builder: (messagesBlocContext, messagesState) {
        return Row(
          children: [
            SizedBox(
              width: 280,
              child: Builder(builder: (context) {
                if (dataState.selectedAddress == null) {
                  return const Center(child: Text('No Address Selected'));
                }
                return ScaffoldPage(
                  header: PageHeader(
                    padding: 10,
                    title: Text(
                      dataState.selectedAddress == null ? 'Inbox' : UiService.getAccountName(dataState.selectedAddress!),
                      style: theme.typography.subtitle,
                    ),
                    commandBar: CommandBar(
                      isCompact: true,
                      mainAxisAlignment: MainAxisAlignment.end,
                      overflowBehavior: CommandBarOverflowBehavior.noWrap,
                      primaryItems: [
                        CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(message: "Address information", child: w),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.info12),
                            label: const Text('Info'),
                            onPressed: () {},
                          ),
                        ),
                        CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(message: "Delete address", child: w),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.delete),
                            label: const Text('Delete'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Builder(builder: (context) {
                    if (dataState.selectedAddress == null) {
                      return const Center(child: Text('No Address Selected'));
                    }
                    return WinuiMessagesList(selectedAddress: dataState.selectedAddress!);
                  }),
                );
              }),
            ),
            const Divider(direction: Axis.vertical),
            Expanded(
              child: Builder(builder: (context) {
                if (dataState.selectedAddress == null) {
                  return const Center(child: Text(''));
                }
                if (messagesState.selectedMessage == null) {
                  return const Center(child: Text(''));
                }
                return ScaffoldPage(
                  header: PageHeader(
                    padding: 10,
                    title: Text(
                      UiService.getMessageFromName(messagesState.selectedMessage!),
                      style: theme.typography.subtitle,
                    ),
                    commandBar: CommandBar(
                      mainAxisAlignment: MainAxisAlignment.end,
                      overflowBehavior: CommandBarOverflowBehavior.noWrap,
                      primaryItems: [
                        CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(message: "Share message", child: w),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.share),
                            label: const Text('Share'),
                            onPressed: () {},
                          ),
                        ),
                        CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(message: "Delete message", child: w),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.delete),
                            label: const Text('Delete'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: RenderMessage(
                    key: Key(messagesState.selectedMessage!.id),
                    user: dataState.selectedAddress!.authenticatedUser,
                    message: messagesState.selectedMessage!,
                  ),
                );
              }),
            )
          ],
        );
      });
    });
  }
}
