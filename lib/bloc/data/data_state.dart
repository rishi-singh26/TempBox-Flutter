import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

class DataState extends Equatable {
  final List<AddressData> addressList;
  final AddressData? selectedAddress;

  final List<Message> messagesList;
  final bool isMessagesLoading;
  final Message? selectedMessage;

  const DataState({
    required this.addressList,
    required this.selectedAddress,
    required this.messagesList,
    required this.isMessagesLoading,
    required this.selectedMessage,
  });

  DataState.initial()
      : addressList = [],
        selectedAddress = null,
        messagesList = [],
        isMessagesLoading = true,
        selectedMessage = null;

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
        'selectedAddress': null,
        'messagesList': [],
        'isMessagesLoading': true,
        'selectedMessage': null,
      };

  factory DataState.fromJson(Map<String, dynamic> json) => DataState(
        addressList: (json['addressList'] as List).map((e) => AddressData.fromJson(e)).toList(),
        selectedAddress: null,
        messagesList: const [],
        isMessagesLoading: true,
        selectedMessage: null,
      );

  @override
  List<Object> get props =>
      [addressList, selectedAddress ?? 'selectedAddress', messagesList, isMessagesLoading, selectedMessage ?? 'SelectedMessage'];

  copyWith({
    List<AddressData>? addressList,
    AddressData? selectedAddress,
    bool? setSelectedAddressToNull,
    List<Message>? messagesList,
    bool? isMessagesLoading,
    Message? selectedMessage,
    bool? setSelectedMessageToNull,
  }) {
    return DataState(
      addressList: addressList ?? this.addressList,
      selectedAddress: setSelectedAddressToNull == true ? null : selectedAddress ?? this.selectedAddress,
      messagesList: messagesList ?? this.messagesList,
      isMessagesLoading: isMessagesLoading ?? this.isMessagesLoading,
      selectedMessage: setSelectedMessageToNull == true ? null : selectedMessage ?? this.selectedMessage,
    );
  }
}
