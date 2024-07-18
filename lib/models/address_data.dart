import 'package:mailtm_client/mailtm_client.dart';

class AddressData {
  final String addressName;
  final AuthenticatedUser authenticatedUser;

  AddressData({required this.addressName, required this.authenticatedUser});

  Map<String, dynamic> toJson() => {
        'addressName': addressName,
        'authenticatedUser': authenticatedUser.toJson(),
      };

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        addressName: json['addressName'],
        authenticatedUser: AuthenticatedUser.fromJson(json['authenticatedUser']),
      );
}
