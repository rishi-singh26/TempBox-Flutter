import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
// ignore: implementation_imports
import 'package:macos_ui/src/library.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macui_address_info.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_export.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_import.dart';
import 'package:tempbox/macos_views/views/macui_removed_addresses/macui_removed_addresses.dart';
import 'package:tempbox/macos_views/views/message_detail/macui_message_detail.dart';
import 'package:tempbox/macos_views/views/selected_address_view/macui_messages_list.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/ui_service.dart';

class SelectedAddressView extends StatefulWidget {
  const SelectedAddressView({super.key});

  @override
  State<SelectedAddressView> createState() => _SelectedAddressViewState();
}

class _SelectedAddressViewState extends State<SelectedAddressView> {
  double ratingValue = 0;
  double capacitorValue = 0;
  double sliderValue = 0.3;

  _showAddressInfo(BuildContext dataBlocContext, AddressData? address) {
    if (address == null) {
      return;
    }
    showMacosSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: MacuiAddressInfo(addressData: address),
      ),
    );
  }

  _refreshInbox(BuildContext dataBlocContext, AddressData? address) {
    if (address == null) {
      return;
    }
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  _toggleMessageSeenStatus(BuildContext dataBlocContext, DataState dataState) {
    if (dataState.selectedAddress == null || dataState.selectedMessage == null) {
      return;
    }
    BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(
      addressData: dataState.selectedAddress!,
      message: dataState.selectedMessage!,
    ));
  }

  _deleteMessage(BuildContext dataBlocContext, DataState dataState) async {
    if (dataState.selectedAddress == null || dataState.selectedMessage == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this message?',
    );
    if (choice == true && context.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteMessageEvent(
        addressData: dataState.selectedAddress!,
        message: dataState.selectedMessage!,
      ));
    }
  }

  _importAddresses(BuildContext context, BuildContext dataBlocContext) async {
    List<AddressData>? addresses = await ExportImportAddress.importAddreses();
    if (context.mounted && addresses != null) {
      showMacosSheet(
        context: context,
        builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: MacuiImport(addresses: addresses)),
      );
    }
  }

  _exportAddresses(BuildContext context, BuildContext dataBlocContext) async {
    await Future.delayed(
      const Duration(milliseconds: 50),
      () => showMacosSheet(
        context: context,
        builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacuiExport()),
      ),
    );
  }

  _removedAddresses(BuildContext context, BuildContext dataBlocContext) async {
    await Future.delayed(
      const Duration(milliseconds: 50),
      () => showMacosSheet(
        context: context,
        builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacUiRemovedAddresses()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) {
        if (previous.accountIdToMessagesMap != current.accountIdToMessagesMap ||
            previous.selectedAddress != current.selectedAddress ||
            previous.selectedMessage != current.selectedMessage) {
          return true;
        }
        return false;
      },
      builder: (dataBlocContext, dataState) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: Builder(builder: (context) {
              if (dataState.selectedAddress == null) {
                return const Text("Inbox");
              }
              List<Message>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(UiService.getAccountName(dataState.selectedAddress!), maxLines: 1),
                  if (messages != null)
                    Text(
                      UiService.getInboxSubtitleFromMessages(messages),
                      style: MacosTheme.of(context).typography.footnote,
                    ),
                ],
              );
            }),
            titleWidth: 150.0,
            actions: [
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.refresh_circled),
                onPressed: dataState.selectedAddress == null ? null : () => _refreshInbox(dataBlocContext, dataState.selectedAddress),
                label: 'Refresh',
                showLabel: false,
                tooltipMessage: 'Refresh inbox',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.info_circle),
                onPressed: dataState.selectedAddress == null ? null : () => _showAddressInfo(dataBlocContext, dataState.selectedAddress),
                label: 'Info',
                showLabel: false,
                tooltipMessage: 'Address information',
              ),
              const ToolBarSpacer(),
              const ToolBarDivider(),
              const ToolBarSpacer(),
              ToolBarIconButton(
                icon: MacosIcon(dataState.selectedMessage?.seen ?? false ? CupertinoIcons.envelope_badge_fill : CupertinoIcons.envelope_open_fill),
                onPressed: dataState.selectedMessage == null ? null : () => _toggleMessageSeenStatus(dataBlocContext, dataState),
                label: dataState.selectedMessage?.seen ?? false ? 'Mark unread' : 'Mark read',
                showLabel: false,
                tooltipMessage: dataState.selectedMessage?.seen ?? false ? 'Mark message as unread' : 'Mark message as read',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.share),
                onPressed: dataState.selectedMessage == null ? null : () {},
                label: 'Share',
                showLabel: false,
                tooltipMessage: 'Share message',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.trash),
                onPressed: dataState.selectedMessage == null ? null : () => _deleteMessage(dataBlocContext, dataState),
                label: 'Delete',
                showLabel: false,
                tooltipMessage: 'Delete message',
              ),
              const ToolBarSpacer(),
              const ToolBarDivider(),
              const ToolBarSpacer(),
              ToolBarPullDownButton(
                label: 'Actions',
                icon: CupertinoIcons.ellipsis_circle,
                tooltipMessage: 'Perform tasks with the selected items',
                items: [
                  MacosPulldownMenuItem(
                    label: 'Import Addresses',
                    title: const Text('Import Addresses'),
                    onTap: () => _importAddresses(context, dataBlocContext),
                  ),
                  MacosPulldownMenuItem(
                    label: 'Export Addresses',
                    title: const Text('Export Addresses'),
                    onTap: () => _exportAddresses(context, dataBlocContext),
                  ),
                  const MacosPulldownMenuDivider(),
                  MacosPulldownMenuItem(
                    label: 'Removed Addresses',
                    title: const Text('Removed Addresses'),
                    onTap: () => _removedAddresses(context, dataBlocContext),
                  ),
                ],
              ),
            ],
          ),
          children: [
            ResizablePane(
              minSize: 280,
              startSize: 300,
              maxSize: 400,
              windowBreakpoint: 700,
              resizableSide: ResizableSide.right,
              builder: (_, __) {
                if (dataState.selectedAddress == null) {
                  return const SizedBox();
                }
                return MacuiMessagesList(key: Key(dataState.selectedAddress!.authenticatedUser.account.id));
              },
            ),
            ContentArea(
              builder: (context, scrollController) {
                return MacuiMessageDetail(key: Key(dataState.selectedMessage?.id ?? 'selectedMessageDetail'));
              },
            ),
          ],
        );
      },
    );
  }
}
