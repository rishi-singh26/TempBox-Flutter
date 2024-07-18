import 'package:equatable/equatable.dart';
import 'package:tempbox/models/address_data.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
}

class AddAddressData extends DataEvent {
  final AddressData address;

  const AddAddressData(this.address);
  @override
  List<Object> get props => [address];
}
