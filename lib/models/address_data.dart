import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';

class AddressData extends Equatable {
  final String addressName;
  final AuthenticatedUser authenticatedUser;
  final bool archived;
  final String password;

  const AddressData({
    required this.addressName,
    required this.authenticatedUser,
    required this.archived,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'addressName': addressName,
        'authenticatedUser': authenticatedUser.toJson(),
        'archived': archived,
        'password': password,
      };

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        addressName: json['addressName'],
        authenticatedUser: AuthenticatedUser.fromJson(json['authenticatedUser']),
        archived: json['archived'],
        password: json['password'],
      );

  AddressData copyWith({bool? archived, AuthenticatedUser? authenticatedUser}) {
    return AddressData(
      addressName: addressName,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser,
      archived: archived ?? this.archived,
      password: password,
    );
  }

  /// return true when address in not deleted or disabled and isactive and false otherwise
  bool get isAddressActive => !authenticatedUser.account.isDeleted && !authenticatedUser.account.isDisabled && !archived;

  @override
  List<Object?> get props => [
        addressName,
        authenticatedUser,
        archived,
        password,
      ];
}
