import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';
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

class DeleteAddressEvent extends DataEvent {
  final AddressData addressData;
  const DeleteAddressEvent(this.addressData);

  @override
  List<Object> get props => [addressData];
}

class GetMessagesEvent extends DataEvent {
  final AddressData addressData;
  final bool? resetMessages;
  const GetMessagesEvent({required this.addressData, this.resetMessages = true});

  @override
  List<Object> get props => [addressData, resetMessages ?? false];
}

class ToggleMessageReadUnread extends DataEvent {
  final Message message;
  final AddressData addressData;
  final bool resetMessages;
  const ToggleMessageReadUnread({required this.addressData, required this.message, this.resetMessages = true});

  @override
  List<Object> get props => [addressData, message, resetMessages];
}

class SelectMessageEvent extends DataEvent {
  final AddressData addressData;
  final Message message;
  const SelectMessageEvent(this.message, this.addressData);

  @override
  List<Object> get props => [message, addressData];
}

class DeleteMessageEvent extends DataEvent {
  final AddressData addressData;
  final Message message;
  final bool resetMessages;
  const DeleteMessageEvent({required this.message, required this.addressData, this.resetMessages = true});

  @override
  List<Object> get props => [message, addressData, resetMessages];
}

class ImportAddresses extends DataEvent {
  final List<AddressData> addresses;
  const ImportAddresses({required this.addresses});

  @override
  List<Object> get props => [addresses];
}
