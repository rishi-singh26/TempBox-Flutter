import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
// ignore: implementation_imports
import 'package:macos_ui/src/library.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/macos_views/views/selected_address_view/macui_messages_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<MessagesBloc, MessagesState>(builder: (messagesBlocContext, messagesState) {
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
                onPressed: () => debugPrint('New Folder...'),
                label: 'Refresh',
                showLabel: false,
                tooltipMessage: 'Refresh inbox',
              ),
              ToolBarIconButton(
                icon: const MacosIcon(CupertinoIcons.trash),
                onPressed: () => debugPrint('New Folder...'),
                label: 'Delete',
                showLabel: false,
                tooltipMessage: 'Delete address',
              ),
              if (messagesState.selectedMessage != null) const ToolBarSpacer(),
              if (messagesState.selectedMessage != null) const ToolBarDivider(),
              if (messagesState.selectedMessage != null) const ToolBarSpacer(),
              if (messagesState.selectedMessage != null)
                ToolBarIconButton(
                  icon: const MacosIcon(CupertinoIcons.trash),
                  onPressed: () => debugPrint('New Folder...'),
                  label: 'Delete',
                  showLabel: false,
                  tooltipMessage: 'Delete message',
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
                return MacuiMessagesList(
                  selectedAddress: dataState.selectedAddress!,
                  key: Key(dataState.selectedAddress!.authenticatedUser.account.id),
                );
              },
            ),
            ContentArea(
              builder: (context, scrollController) {
                if (dataState.selectedAddress == null) {
                  return const Center(child: Text('No Address Selected'));
                }
                if (messagesState.selectedMessage == null) {
                  return const Center(child: Text('No Message Selected'));
                }
                return RenderMessage(
                  key: Key(messagesState.selectedMessage!.id),
                  user: dataState.selectedAddress!.authenticatedUser,
                  message: messagesState.selectedMessage!,
                );
              },
            ),
          ],
        );
      });
    });
  }
}
