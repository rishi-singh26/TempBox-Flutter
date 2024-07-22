import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
// ignore: implementation_imports
import 'package:macos_ui/src/library.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macui_address_info.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_export.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_import.dart';
import 'package:tempbox/macos_views/views/selected_address_view/macui_messages_list.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return MacosScaffold(
        toolBar: ToolBar(
          title: Text(
            dataState.selectedAddress == null ? "Inbox" : UiService.getAccountName(dataState.selectedAddress!),
          ),
          titleWidth: 150.0,
          leading: MacosTooltip(
            message: 'Toggle Sidebar',
            useMousePosition: false,
            child: MacosIconButton(
              icon: MacosIcon(
                CupertinoIcons.sidebar_left,
                color: MacosTheme.brightnessOf(context).resolve(
                  const Color.fromRGBO(0, 0, 0, 0.5),
                  const Color.fromRGBO(255, 255, 255, 0.5),
                ),
                size: 20.0,
              ),
              boxConstraints: const BoxConstraints(
                minHeight: 20,
                minWidth: 20,
                maxWidth: 48,
                maxHeight: 38,
              ),
              onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
            ),
          ),
          actions: [
            ToolBarIconButton(
              icon: const MacosIcon(CupertinoIcons.refresh_circled),
              onPressed: dataState.selectedAddress == null
                  ? null
                  : () => BlocProvider.of<DataBloc>(context).add(GetMessagesEvent(addressData: dataState.selectedAddress!)),
              label: 'Refresh',
              showLabel: false,
              tooltipMessage: 'Refresh inbox',
            ),
            ToolBarIconButton(
              icon: const MacosIcon(CupertinoIcons.info_circle),
              onPressed: dataState.selectedAddress == null
                  ? null
                  : () => showMacosSheet(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<DataBloc>(dataBlocContext),
                          child: MacuiAddressInfo(addressData: dataState.selectedAddress!),
                        ),
                      ),
              label: 'Info',
              showLabel: false,
              tooltipMessage: 'Address information',
            ),
            ToolBarIconButton(
              icon: const MacosIcon(CupertinoIcons.trash),
              onPressed: dataState.selectedAddress == null
                  ? null
                  : () async {
                      final choice = await AlertService.getConformation<bool>(
                        context: context,
                        title: 'Alert',
                        content: 'Are you sure you want to delete this address?',
                      );
                      if (choice == true && context.mounted) {
                        BlocProvider.of<DataBloc>(context).add(DeleteAddressEvent(dataState.selectedAddress!));
                      }
                    },
              label: 'Delete',
              showLabel: false,
              tooltipMessage: 'Delete address',
            ),
            const ToolBarSpacer(),
            const ToolBarDivider(),
            const ToolBarSpacer(),
            ToolBarIconButton(
              icon: MacosIcon(dataState.selectedMessage?.seen ?? false ? CupertinoIcons.envelope_badge_fill : CupertinoIcons.envelope_open_fill),
              onPressed: dataState.selectedMessage == null
                  ? null
                  : () => BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(
                        addressData: dataState.selectedAddress!,
                        message: dataState.selectedMessage!,
                      )),
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
                        ));
                      }
                    },
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
              if (dataState.selectedAddress == null) {
                return const Center(child: Text('No Address Selected'));
              }
              if (dataState.selectedMessage == null) {
                return const Center(child: Text('No Message Selected'));
              }
              return RenderMessage(
                key: Key(dataState.selectedMessage!.id),
                user: dataState.selectedAddress!.authenticatedUser,
                message: dataState.selectedMessage!,
              );
            },
          ),
        ],
      );
    });
  }
}
