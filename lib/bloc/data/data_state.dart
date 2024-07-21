import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

class DataState extends Equatable {
  final List<AddressData> addressList;
  final AddressData? selectedAddress;

  const DataState({
    required this.addressList,
    required this.selectedAddress,
  });

  DataState.initial()
      : addressList = [],
        selectedAddress = null;

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
        'selectedAddress': null,
      };

  factory DataState.fromJson(Map<String, dynamic> json) => DataState(
        addressList: (json['addressList'] as List).map((e) => AddressData.fromJson(e)).toList(),
        selectedAddress: null,
      );

  @override
  List<Object> get props => [addressList, selectedAddress ?? 'selectedAddress'];

  copyWith({
    List<AddressData>? addressList,
    AddressData? selectedAddress,
    Message? selectedMessage,
  }) {
    return DataState(
      addressList: addressList ?? this.addressList,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }
}
