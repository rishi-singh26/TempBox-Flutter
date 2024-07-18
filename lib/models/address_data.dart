import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';

class AddressData extends Equatable {
  final String addressName;
  final AuthenticatedUser authenticatedUser;
  final bool isActive;
  final String password;

  const AddressData({
    required this.addressName,
    required this.authenticatedUser,
    required this.isActive,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'addressName': addressName,
        'authenticatedUser': authenticatedUser.toJson(),
        'isAactive': isActive,
        'password': password,
      };

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        addressName: json['addressName'],
        authenticatedUser: AuthenticatedUser.fromJson(json['authenticatedUser']),
        isActive: json['isAactive'],
        password: json['password'],
      );

  AddressData copyWith({bool? isActive}) {
    return AddressData(
      addressName: addressName,
      authenticatedUser: authenticatedUser,
      isActive: isActive ?? this.isActive,
      password: password,
    );
  }

  @override
  List<Object?> get props => [
        addressName,
        authenticatedUser,
        isActive,
        password,
      ];
}