import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';
import 'package:tempbox/win_views/views/selected_address_view/winui_messages_list.dart';
import 'package:tempbox/win_views/views/winui_address_info/winui_address_info.dart';

class WinuiSelectedAddressView extends StatelessWidget {
  final menuController = FlyoutController();
  WinuiSelectedAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
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
                  commandBar: FlyoutTarget(
                    controller: menuController,
                    child: IconButton(
                      icon: const Icon(FluentIcons.more, size: 16),
                      onPressed: () => menuController.showFlyout(
                        autoModeConfiguration: FlyoutAutoConfiguration(
                          preferredMode: FlyoutPlacementMode.bottomCenter,
                        ),
                        barrierDismissible: true,
                        dismissOnPointerMoveAway: false,
                        dismissWithEsc: true,
                        builder: (context) {
                          return MenuFlyout(
                            items: [
                              MenuFlyoutItem(
                                leading: const Icon(CupertinoIcons.refresh_thick),
                                text: const Text('Refresh inbox'),
                                onPressed: dataState.selectedAddress == null
                                    ? null
                                    : () {
                                        Flyout.of(context).close();
                                        BlocProvider.of<DataBloc>(dataBlocContext).add(
                                          GetMessagesEvent(addressData: dataState.selectedAddress!, resetMessages: false),
                                        );
                                      },
                              ),
                              MenuFlyoutItem(
                                leading: const Icon(FluentIcons.info12),
                                text: const Text('Info'),
                                onPressed: dataState.selectedAddress == null
                                    ? null
                                    : () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: BlocProvider.of<DataBloc>(dataBlocContext),
                                            child: WinuiAddressInfo(addressData: dataState.selectedAddress!),
                                          ),
                                        );
                                        context.mounted ? Flyout.of(context).close() : null;
                                      },
                              ),
                              MenuFlyoutItem(
                                leading: const Icon(FluentIcons.delete),
                                text: const Text('Delete address'),
                                onPressed: dataState.selectedAddress == null
                                    ? null
                                    : () async {
                                        final choice = await AlertService.getConformation<bool>(
                                          context: context,
                                          title: 'Alert',
                                          content: 'Are you sure you want to delete this address?',
                                        );
                                        if (choice == true && dataBlocContext.mounted) {
                                          BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(dataState.selectedAddress!));
                                        }
                                        context.mounted ? Flyout.of(context).close() : null;
                                      },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
              if (dataState.selectedMessage == null) {
                return const Center(child: Text(''));
              }
              return ScaffoldPage(
                header: PageHeader(
                  padding: 10,
                  title: Text(
                    UiService.getMessageFromName(dataState.selectedMessage!),
                    style: theme.typography.subtitle,
                  ),
                  commandBar: CommandBar(
                    isCompact: true,
                    mainAxisAlignment: MainAxisAlignment.end,
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [
                      CommandBarBuilderItem(
                        builder: (context, mode, w) => Tooltip(
                          message: dataState.selectedMessage?.seen ?? false ? 'Mark message as unread' : 'Mark message as read',
                          child: w,
                        ),
                        wrappedItem: CommandBarButton(
                          icon: Icon(dataState.selectedMessage?.seen ?? false ? CupertinoIcons.envelope_badge : CupertinoIcons.envelope_open),
                          label: Text(dataState.selectedMessage?.seen ?? false ? 'Mark unread' : 'Mark read'),
                          onPressed: dataState.selectedMessage == null
                              ? null
                              : () => BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(
                                    addressData: dataState.selectedAddress!,
                                    message: dataState.selectedMessage!,
                                    resetMessages: false,
                                  )),
                        ),
                      ),
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
                            onPressed: dataState.selectedMessage == null
                                ? null
                                : () async {
                                    final choice = await AlertService.getConformation<bool>(
                                      context: context,
                                      title: 'Alert',
                                      content: 'Are you sure you want to delete this message?',
                                    );
                                    if (choice == true && context.mounted) {
                                      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteMessageEvent(
                                        addressData: dataState.selectedAddress!,
                                        message: dataState.selectedMessage!,
                                        resetMessages: false,
                                      ));
                                    }
                                  }),
                      ),
                    ],
                  ),
                ),
                content: RenderMessage(
                  key: Key(dataState.selectedMessage!.id),
                  user: dataState.selectedAddress!.authenticatedUser,
                  message: dataState.selectedMessage!,
                ),
              );
            }),
          )
        ],
      );
    });
  }
}
