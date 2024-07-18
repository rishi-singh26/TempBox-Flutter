import 'package:tempbox/models/address_data.dart';

class UiService {
  static getAccountName(AddressData addressData) {
    return addressData.addressName.isNotEmpty ? addressData.addressName : addressData.authenticatedUser.account.address.split('@').first;
  }
}
