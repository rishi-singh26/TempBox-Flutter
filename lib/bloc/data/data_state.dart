import 'package:equatable/equatable.dart';
import 'package:tempbox/models/address_data.dart';

class DataState extends Equatable {
  final List<AddressData> addressList;

  const DataState({required this.addressList});

  DataState.initial() : addressList = [];

  Map<String, dynamic> toJson() => {
        'addressList': addressList.map((e) => e.toJson()).toList(),
      };

  factory DataState.fromJson(Map<String, dynamic> json) => DataState(
        addressList: (json['addressList'] as List).map((e) => AddressData.fromJson(e)).toList(),
      );

  @override
  List<Object> get props => [
        addressList,
      ];

  copyWith({List<AddressData>? addressList}) {
    return DataState(
      addressList: addressList ?? this.addressList,
    );
  }
}
