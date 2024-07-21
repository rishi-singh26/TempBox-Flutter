part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => [];
}

class GetMessagesEvent extends MessagesEvent {
  final AddressData addressData;
  final bool? resetMessages;
  const GetMessagesEvent({required this.addressData, this.resetMessages = true});

  @override
  List<Object> get props => [addressData];
}

class ToggleMessageReadUnread extends MessagesEvent {
  final Message message;
  final AddressData addressData;
  const ToggleMessageReadUnread(this.addressData, this.message);

  @override
  List<Object> get props => [addressData, message];
}

class SelectMessageEvent extends MessagesEvent {
  final AddressData addressData;
  final Message message;
  const SelectMessageEvent(this.message, this.addressData);

  @override
  List<Object> get props => [message, addressData];
}

class RemoveMessageSelectionEvent extends MessagesEvent {
  const RemoveMessageSelectionEvent();

  @override
  List<Object> get props => [];
}

class DeleteMessageEvent extends MessagesEvent {
  final AddressData addressData;
  final Message message;
  const DeleteMessageEvent(this.message, this.addressData);

  @override
  List<Object> get props => [message, addressData];
}
