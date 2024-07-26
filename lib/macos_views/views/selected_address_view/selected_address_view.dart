import 'package:fluent_ui/fluent_ui.dart';
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
    showMacosSheet(
      context: context,
      builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacuiExport()),
    );
  }

  _toggleArchiveAddress(BuildContext dataBlocContext, AddressData? address) async {
    if (address == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to ${address.isActive == true ? 'archive' : 'activate'} this address?',
    );
    if (choice == true && dataBlocContext.mounted) {
      if (address.isActive == true) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(ArchiveAddressEvent(address));
      } else {
        BlocProvider.of<DataBloc>(dataBlocContext).add(UnarchiveAddressEvent(address));
      }
    }
  }

  _deleteAddress(BuildContext dataBlocContext, AddressData? address) async {
    if (address == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this address?',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(address));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) {
        if (previous.accountIdToAddressesMap != current.accountIdToAddressesMap ||
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
              List<Message>? messages = dataState.accountIdToAddressesMap[dataState.selectedAddress!.authenticatedUser.account.id];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(UiService.getAccountName(dataState.selectedAddress!)),
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
              if (dataState.selectedAddress?.isActive == true)
                ToolBarIconButton(
                  icon: const MacosIcon(CupertinoIcons.refresh_circled),
                  onPressed: dataState.selectedAddress == null || dataState.selectedAddress?.isActive != true
                      ? null
                      : () => _refreshInbox(dataBlocContext, dataState.selectedAddress),
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
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.archivebox),
                onPressed: dataState.selectedAddress == null ? null : () => _toggleArchiveAddress(dataBlocContext, dataState.selectedAddress),
                label: 'Archive',
                showLabel: false,
                tooltipMessage: dataState.selectedAddress?.isActive == true ? 'Archive address' : 'Activate Address',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.trash),
                onPressed: dataState.selectedAddress == null ? null : () => _deleteAddress(dataBlocContext, dataState.selectedAddress),
                label: 'Delete',
                showLabel: false,
                tooltipMessage: 'Delete address',
              ),
              const ToolBarSpacer(),
              const ToolBarDivider(),
              const ToolBarSpacer(),
              ToolBarIconButton(
                icon: MacosIcon(dataState.selectedMessage?.seen ?? false ? CupertinoIcons.envelope_badge_fill : CupertinoIcons.envelope_open_fill),
                onPressed: dataState.selectedMessage == null || dataState.selectedAddress?.isActive != true
                    ? null
                    : () => _toggleMessageSeenStatus(dataBlocContext, dataState),
                label: dataState.selectedMessage?.seen ?? false ? 'Mark unread' : 'Mark read',
                showLabel: false,
                tooltipMessage: dataState.selectedMessage?.seen ?? false ? 'Mark message as unread' : 'Mark message as read',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.share),
                onPressed: dataState.selectedMessage == null || dataState.selectedAddress?.isActive != true ? null : () {},
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
              ToolBarIconButton(
                icon: const MacosIcon(FluentIcons.import),
                onPressed: () => _importAddresses(context, dataBlocContext),
                label: 'Import',
                showLabel: false,
                tooltipMessage: 'Import addreses',
              ),
              if (dataState.addressList.isNotEmpty)
                ToolBarIconButton(
                  icon: const MacosIcon(FluentIcons.export),
                  onPressed: () => _exportAddresses(context, dataBlocContext),
                  label: 'Export',
                  showLabel: false,
                  tooltipMessage: 'Export addreses',
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
