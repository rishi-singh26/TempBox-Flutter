import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';

class WinuiMessagesList extends StatefulWidget {
  const WinuiMessagesList({super.key});

  @override
  State<WinuiMessagesList> createState() => _WinuiMessagesListState();
}

class _WinuiMessagesListState extends State<WinuiMessagesList> {
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = -1;

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
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null) {
        return const Center(child: Text('No address selected'));
      }
      List<MessageData>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null || messages.isEmpty) {
        return const Center(child: Text('No Messages'));
      }
      return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (FocusNode _, KeyEvent event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() => _addToSelectedIndex(1, messages.length));
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() => _addToSelectedIndex(-1, messages.length));
              return KeyEventResult.handled;
            }
          }
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter && _selectedIndex >= 0 && _selectedIndex < messages.length) {
              BlocProvider.of<DataBloc>(dataBlocContext).add(
                SelectMessageEvent(message: messages[_selectedIndex], addressData: dataState.selectedAddress!),
              );
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            MessageData message = messages[index];
            String title = UiService.getMessageFromName(message);
            title = title.length > 22 ? title.substring(0, 21) : title;
            return ListTile.selectable(
              selected: _selectedIndex == index,
              onSelectionChange: (v) {
                _setSelectedIndex(index);
                BlocProvider.of<DataBloc>(dataBlocContext).add(SelectMessageEvent(message: message, addressData: dataState.selectedAddress!));
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: message.seen ? 130 : 100, child: Text(title)),
                  Text(
                    UiService.formatTimeTo12Hour(message.createdAt),
                    style: FluentTheme.of(context).typography.caption,
                  ),
                ],
              ),
              subtitle: Text(message.subject),
              leading: !message.seen ? BlankBadge(color: Colors.blue) : null,
            );
          },
        ),
      );
    });
  }
}
