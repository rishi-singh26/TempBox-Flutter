import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

class DataState extends Equatable {
  /// list of addresses, saved to persistan storage
  final List<AddressData> addressList;

  /// The currently selected address, it persists with app restart
  final AddressData? selectedAddress;

  /// The currently selected address, does not persist app restart
  final Message? selectedMessage;

  /// map of account id to list of messages
  final Map<String, List<Message>> accountIdToMessagesMap;

  /// Map of messageId to message data, used to store the complete message data that includes the html
  /// so we dont need to fetch the message every time and messages can be accessed offline.
  /// It will store message which user hase opened and all messages for archived accounts.
  final Map<String, Message> messageIdToMessageMap;

  const DataState({
    required this.addressList,
    required this.selectedAddress,
    required this.selectedMessage,
    required this.accountIdToMessagesMap,
    required this.messageIdToMessageMap,
  });

  DataState.initial()
      : addressList = [],
        selectedAddress = null,
        selectedMessage = null,
        accountIdToMessagesMap = {},
        messageIdToMessageMap = {};

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
        'selectedAddress': selectedAddress?.toJson(),
        'selectedMessage': selectedMessage?.toJson(),
        'accountIdToMessagesMap': accountIdToMessagesMap.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
        'messageIdToMessageMap': messageIdToMessageMap.map((key, value) => MapEntry(key, value.toJson())),
      };

  factory DataState.fromJson(Map<String, dynamic> json) => DataState(
        addressList: (json['addressList'] as List).map((e) => AddressData.fromJson(e)).toList(),
        selectedAddress:
            json.containsKey('selectedAddress') && json['selectedAddress'] != null ? AddressData.fromJson(json['selectedAddress']) : null,
        // selectedMessage: json.containsKey('selectedMessage') && json['selectedMessage'] != null ? Message.fromJson(json['selectedMessage']) : null,
        selectedMessage: null,
        accountIdToMessagesMap: (json['accountIdToMessagesMap'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as List).map((e) => Message.fromJson(e)).toList()),
        ),
        messageIdToMessageMap: (json['messageIdToMessageMap'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Message.fromJson(value))),
      );

  @override
  List<Object> get props => [
        addressList,
        selectedAddress ?? 'selectedAddress',
        selectedMessage ?? 'SelectedMessage',
        accountIdToMessagesMap,
        messageIdToMessageMap,
      ];

  copyWith({
    List<AddressData>? addressList,
    AddressData? selectedAddress,
    bool? setSelectedAddressToNull,
    Message? selectedMessage,
    bool? setSelectedMessageToNull,
    Map<String, List<Message>>? accountIdToMessagesMap,
    Map<String, Message>? messageIdToMessageMap,
  }) {
    return DataState(
      addressList: addressList ?? this.addressList,
      selectedAddress: setSelectedAddressToNull == true ? null : selectedAddress ?? this.selectedAddress,
      selectedMessage: setSelectedMessageToNull == true ? null : selectedMessage ?? this.selectedMessage,
      accountIdToMessagesMap: accountIdToMessagesMap ?? this.accountIdToMessagesMap,
      messageIdToMessageMap: messageIdToMessageMap ?? this.messageIdToMessageMap,
    );
  }
}
