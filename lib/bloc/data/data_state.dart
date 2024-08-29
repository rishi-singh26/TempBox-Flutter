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
  /// It will store message which user has opened and all messages for archived accounts.
  final Map<String, Message> messageIdToMessageMap;

  /// List of removed addresses, these addresses can be restored
  final List<AddressData> removedAddresses;

  const DataState({
    required this.addressList,
    required this.selectedAddress,
    required this.selectedMessage,
    required this.accountIdToMessagesMap,
    required this.messageIdToMessageMap,
    required this.removedAddresses,
  });

  DataState.initial()
      : addressList = [],
        selectedAddress = null,
        selectedMessage = null,
        accountIdToMessagesMap = {},
        messageIdToMessageMap = {},
        removedAddresses = [];

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
        'selectedAddress': selectedAddress?.toJson(),
        'selectedMessage': selectedMessage?.toJson(),
        'accountIdToMessagesMap': accountIdToMessagesMap.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
        'messageIdToMessageMap': messageIdToMessageMap.map((key, value) => MapEntry(key, value.toJson())),
        'removedAddresses': removedAddresses.map((e) => e.toJson()).toList(),
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
        removedAddresses: json.containsKey('removedAddresses') ? (json['removedAddresses'] as List).map((e) => AddressData.fromJson(e)).toList() : [],
      );

  @override
  List<Object> get props => [
        addressList,
        selectedAddress ?? 'selectedAddress',
        selectedMessage ?? 'SelectedMessage',
        accountIdToMessagesMap,
        messageIdToMessageMap,
        removedAddresses,
      ];

  copyWith({
    List<AddressData>? addressList,
    AddressData? selectedAddress,
    bool? setSelectedAddressToNull,
    Message? selectedMessage,
    bool? setSelectedMessageToNull,
    Map<String, List<Message>>? accountIdToMessagesMap,
    Map<String, Message>? messageIdToMessageMap,
    List<AddressData>? removedAddresses,
  }) {
    return DataState(
      addressList: addressList ?? this.addressList,
      selectedAddress: setSelectedAddressToNull == true ? null : selectedAddress ?? this.selectedAddress,
      selectedMessage: setSelectedMessageToNull == true ? null : selectedMessage ?? this.selectedMessage,
      accountIdToMessagesMap: accountIdToMessagesMap ?? this.accountIdToMessagesMap,
      messageIdToMessageMap: messageIdToMessageMap ?? this.messageIdToMessageMap,
      removedAddresses: removedAddresses ?? this.removedAddresses,
    );
  }
}
