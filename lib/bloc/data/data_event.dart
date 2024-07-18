import 'package:equatable/equatable.dart';
import 'package:tempbox/models/address_data.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
}

class AddAddressDataEvent extends DataEvent {
  final AddressData address;

  const AddAddressDataEvent(this.address);
  @override
  List<Object> get props => [address];
}

class LoginToAccountsEvent extends DataEvent {
  const LoginToAccountsEvent();

  @override
  List<Object> get props => [];
}

class SelectAddressEvent extends DataEvent {
  final AddressData addressData;
  const SelectAddressEvent(this.addressData);

  @override
  List<Object> get props => [addressData];
}
