import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

class DataState extends Equatable {
  final List<AddressData> addressList;
  final AddressData? selectedAddress;
  final Message? selectedMessage;

  const DataState({
    required this.addressList,
    required this.selectedAddress,
    required this.selectedMessage,
  });

  DataState.initial()
      : addressList = [],
        selectedAddress = null,
        selectedMessage = null;

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
        'selectedAddress': selectedAddress == null ? selectedAddress : selectedAddress!.toJson(),
        'selectedMessage': selectedMessage == null ? selectedMessage : selectedMessage!.toJson(),
      };

  factory DataState.fromJson(Map<String, dynamic> json) => DataState(
        addressList: (json['addressList'] as List).map((e) => AddressData.fromJson(e)).toList(),
        selectedAddress: json.containsKey('selectedAddress')
            ? json['selectedAddress'] == null
                ? null
                : AddressData.fromJson(json['selectedAddress'])
            : null,
        selectedMessage: json.containsKey('selectedMessage')
            ? json['selectedMessage'] == null
                ? null
                : Message.fromJson(json['selectedMessage'])
            : null,
      );

  @override
  List<Object> get props => [addressList, selectedAddress ?? 'selectedAddress', selectedMessage ?? 'selectedMessage'];

  copyWith({
    List<AddressData>? addressList,
    AddressData? selectedAddress,
    Message? selectedMessage,
  }) {
    return DataState(
      addressList: addressList ?? this.addressList,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedMessage: selectedMessage ?? this.selectedMessage,
    );
  }
}
