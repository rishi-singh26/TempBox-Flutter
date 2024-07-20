import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/macos_views/views/selected_address_view/macui_message_tile.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class MacuiMessagesList extends StatefulWidget {
  final AddressData selectedAddress;
  const MacuiMessagesList({super.key, required this.selectedAddress});

  @override
  State<MacuiMessagesList> createState() => _MacuiMessagesListState();
}

class _MacuiMessagesListState extends State<MacuiMessagesList> {
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;

  @override
  void initState() {
    BlocProvider.of<MessagesBloc>(context).add(GetMessagesEvent(widget.selectedAddress));
    super.initState();
  }

  void _setSelectedIndex(int newIndex) {
    _selectedIndex = newIndex;
  }

  void _addToSelectedIndex(int value, int itemCount) {
    if (value > 0 && _selectedIndex == itemCount - 1) {
      return;
    }
    if (value < 0 && _selectedIndex == 0) {
      return;
    }
    _setSelectedIndex(_selectedIndex + value);
  }

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    final secondaryTypography = MacosTypography(
      color: MacosTheme.brightnessOf(context).isDark ? MacosColors.secondaryLabelColor.darkColor : MacosColors.secondaryLabelColor,
    );
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<MessagesBloc, MessagesState>(builder: (messagesBlocContext, messagesState) {
        if (dataState.selectedAddress == null) {
          return const Center(child: Text('No address selected'));
        }
        if (messagesState.messagesList.isEmpty) {
          return const Center(child: Text('No Messages'));
        }
        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (FocusNode _, KeyEvent event) {
            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() => _addToSelectedIndex(1, messagesState.messagesList.length));
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() => _addToSelectedIndex(-1, messagesState.messagesList.length));
                return KeyEventResult.handled;
              }
            }
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter && _selectedIndex >= 0 && _selectedIndex < messagesState.messagesList.length) {
                BlocProvider.of<MessagesBloc>(dataBlocContext).add(
                  SelectMessageEvent(messagesState.messagesList[_selectedIndex], dataState.selectedAddress!),
                );
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: ListView.builder(
            itemCount: messagesState.messagesList.length,
            itemBuilder: (context, index) {
              Message message = messagesState.messagesList[index];
              return MacuiMessageTile(
                selectedIndex: _selectedIndex,
                index: index,
                select: () => setState(() {
                  _setSelectedIndex(index);
                  BlocProvider.of<MessagesBloc>(dataBlocContext).add(SelectMessageEvent(message, dataState.selectedAddress!));
                }),
                selectedColor: CupertinoColors.systemBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(UiService.getMessageFromName(message), style: typography.body.copyWith(fontWeight: MacosFontWeight.w510), maxLines: 1),
                    Text(message.subject, style: secondaryTypography.callout, maxLines: 2),
                    if (message.intro.isNotEmpty) Text(message.intro, style: secondaryTypography.callout, maxLines: 2),
                  ],
                ),
              );
            },
          ),
        );
      });
    });
  }
}
