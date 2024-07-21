import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesState.initial()) {
    on<GetMessagesEvent>((GetMessagesEvent event, Emitter<MessagesState> emit) async {
      emit(state.copyWith(messagesList: [], isMessagesLoading: true));
      final messages = await event.addressData.authenticatedUser.messagesAt(1);
      emit(state.copyWith(messagesList: messages, isMessagesLoading: false));
    });

    on<ToggleMessageReadUnread>((ToggleMessageReadUnread event, Emitter<MessagesState> emit) async {
      if (event.message.seen) {
        await event.addressData.authenticatedUser.unreadMessage(event.message.id);
      } else {
        await event.addressData.authenticatedUser.readMessage(event.message.id);
      }
      add(GetMessagesEvent(event.addressData));
    });

    on<SelectMessageEvent>((SelectMessageEvent event, Emitter<MessagesState> emit) async {
      await event.addressData.authenticatedUser.readMessage(event.message.id);
      emit(state.copyWith(selectedMessage: event.message));
    });

    on<DeleteMessageEvent>((DeleteMessageEvent event, Emitter<MessagesState> emit) async {
      await event.addressData.authenticatedUser.deleteMessage(event.message.id);
      emit(state.copyWith(messagesList: state.messagesList.where((m) => m.id != event.message.id).toList()));
    });

    on<RemoveMessageSelectionEvent>((RemoveMessageSelectionEvent event, Emitter<MessagesState> emit) async {
      emit(state.copyWith(setSelectedMessageToNull: true));
    });
  }
}
