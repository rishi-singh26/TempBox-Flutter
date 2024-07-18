part of 'messages_bloc.dart';

class MessagesState extends Equatable {
  final List<Message> messagesList;
  final bool isMessagesLoading;
  final Message? selectedMessage;

  const MessagesState({
    required this.messagesList,
    required this.isMessagesLoading,
    required this.selectedMessage,
  });

  MessagesState.initial()
      : messagesList = [],
        isMessagesLoading = true,
        selectedMessage = null;

  @override
  List<Object> get props => [messagesList, isMessagesLoading, selectedMessage ?? 'SelectedMessage'];

  MessagesState copyWith({List<Message>? messagesList, bool? isMessagesLoading, Message? selectedMessage}) {
    return MessagesState(
      messagesList: messagesList ?? this.messagesList,
      isMessagesLoading: isMessagesLoading ?? this.isMessagesLoading,
      selectedMessage: selectedMessage ?? this.selectedMessage,
    );
  }
}
