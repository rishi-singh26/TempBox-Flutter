import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/provide_color.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';

class MacuiMessagesList extends StatefulWidget {
  const MacuiMessagesList({super.key});

  @override
  State<MacuiMessagesList> createState() => _MacuiMessagesListState();
}

class _MacuiMessagesListState extends State<MacuiMessagesList> {
  final scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;

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
    final typography = MacosTheme.of(context).typography;
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null) {
        return const Center(child: Text('No address selected'));
      }
      List<MessageData>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null || messages.isEmpty) {
        return const Center(child: Text('Inbox empty'));
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
        child: Scrollbar(
          controller: scrollController,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            separatorBuilder: (context, index) => index == _selectedIndex || index == _selectedIndex - 1
                ? const SizedBox.shrink()
                : const Divider(indent: 15, endIndent: 15, thickness: 0, height: 0),
            itemBuilder: (context, index) {
              MessageData message = messages[index];
              String title = UiService.getMessageFromName(message);
              title = title.length > 22 ? title.substring(0, 21) : title;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ? ProvideColor.getSelectedColor(
                          accentColor: MacosTheme.of(context).accentColor ?? AccentColor.blue,
                          isDarkModeEnabled: MacosTheme.of(context).brightness.isDark,
                          isWindowMain: true,
                        )
                      : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                clipBehavior: Clip.hardEdge,
                child: MacosListTile(
                  onClick: () => setState(() {
                    _setSelectedIndex(index);
                    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectMessageEvent(message: message, addressData: dataState.selectedAddress!));
                  }),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (!message.seen)
                                BlankBadge(
                                  color: index == _selectedIndex
                                      ? MacosColors.white
                                      : ProvideColor.getSelectedColor(
                                          accentColor: MacosTheme.of(context).accentColor ?? AccentColor.blue,
                                          isDarkModeEnabled: MacosTheme.of(context).brightness.isDark,
                                          isWindowMain: true,
                                        ),
                                ),
                              if (!message.seen) const SizedBox(width: 7),
                              Text(title, style: typography.body.copyWith(fontWeight: MacosFontWeight.w510), maxLines: 1),
                            ],
                          ),
                          Text(
                            UiService.formatTimeTo12Hour(message.createdAt),
                            style: typography.callout,
                          ),
                        ],
                      ),
                      Text(message.subject, style: typography.callout, maxLines: 2),
                      if (message.intro.isNotEmpty) Text(message.intro, style: typography.callout, maxLines: 2),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
