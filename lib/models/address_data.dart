import 'package:equatable/equatable.dart';
import 'package:mailtm_client/mailtm_client.dart';

class AddressData extends Equatable {
  final String addressName;
  final AuthenticatedUser authenticatedUser;
  final String password;

  const AddressData({
    required this.addressName,
    required this.authenticatedUser,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'addressName': addressName,
        'authenticatedUser': authenticatedUser.toJson(),
        'password': password,
      };

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        addressName: json['addressName'],
        authenticatedUser: AuthenticatedUser.fromJson(json['authenticatedUser']),
        password: json['password'],
      );

  AddressData copyWith({bool? archived, AuthenticatedUser? authenticatedUser}) {
    return AddressData(
      addressName: addressName,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser,
      password: password,
    );
  }

  /// return true when address in not deleted or disabled and isactive and false otherwise
  bool get isAddressActive => !authenticatedUser.account.isDeleted && !authenticatedUser.account.isDisabled;

  @override
  List<Object?> get props => [
        addressName,
        authenticatedUser,
        password,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressData && runtimeType == other.runtimeType && authenticatedUser.account.id == other.authenticatedUser.account.id;

  @override
  int get hashCode => authenticatedUser.account.id.hashCode;
}
