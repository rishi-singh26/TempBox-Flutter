import 'dart:convert';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/crypto_service.dart';
import 'package:tempbox/services/fs_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';

class _VersionContainer {
  final String version;

  _VersionContainer({required this.version});

  factory _VersionContainer.fromJson(Map<String, dynamic> json) {
    return _VersionContainer(version: json['version']);
  }
}

class _ExportVersionOne {
  static const String version = '1.0.0';
  final DateTime exportDate;
  final List<AddressData> addresses;

  _ExportVersionOne({required this.exportDate, required this.addresses});

  Map<String, dynamic> toJson() {
    return {'version': version, 'exportDate': exportDate.toIso8601String(), 'addresses': addresses.map((e) => e.toJson()).toList()};
  }

  factory _ExportVersionOne.fromJson(Map<String, dynamic> json) {
    final decodedVersion = json['version'];
    if (decodedVersion != version) {
      throw FormatException("Unsupported version: $decodedVersion. Expected version: $version.");
    }

    return _ExportVersionOne(exportDate: json['exportDate'], addresses: (json['addresses'] as List).map((e) => AddressData.fromJson(e)).toList());
  }

  String toJsonString({bool pretty = true}) {
    final encoder = pretty ? JsonEncoder.withIndent('  ') : JsonEncoder();
    return encoder.convert(toJson());
  }
}

class _ExportVersionTwo {
  static const String version = "2.0.0";
  final DateTime exportDate;
  final List<_ExportVersionTwoAddress> addresses;

  _ExportVersionTwo({required this.exportDate, required this.addresses});

  // Factory constructor with automatic exportDate (like Swift init)
  factory _ExportVersionTwo.withAddresses(List<_ExportVersionTwoAddress> addresses) {
    return _ExportVersionTwo(exportDate: DateTime.now(), addresses: addresses);
  }

  // Deserialize from JSON
  factory _ExportVersionTwo.fromJson(Map<String, dynamic> json) {
    final decodedVersion = json['version'];
    if (decodedVersion != version) {
      throw FormatException("Unsupported version: $decodedVersion. Expected version: $version.");
    }

    return _ExportVersionTwo(
      exportDate: DateTime.parse(json['exportDate']),
      addresses: (json['addresses'] as List).map((e) => _ExportVersionTwoAddress.fromJson(e)).toList(),
    );
  }

  // Serialize to JSON Map
  Map<String, dynamic> toJson() => {
    'version': version,
    'exportDate': exportDate.toIso8601String(),
    'addresses': addresses.map((e) => e.toJson()).toList(),
  };

  // Convert to pretty JSON string
  String toJsonString({bool pretty = true}) {
    final encoder = pretty ? JsonEncoder.withIndent('  ') : JsonEncoder();
    return encoder.convert(toJson());
  }

  // Convert to CSV string
  String toCSV() {
    final buffer = StringBuffer();
    buffer.writeln('Address Name,Email,Password,Archived,Created At,ID');

    for (final address in addresses) {
      final row = [address.addressName ?? '', address.email, address.password, address.archived, address.createdAt, address.id]
          .map((field) {
            final escaped = field.replaceAll('"', '""');
            return '"$escaped"';
          })
          .join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }
}

class _ExportVersionTwoAddress {
  final String? addressName;
  final String id;
  final String email;
  final String password;
  final String archived;
  final String createdAt;

  _ExportVersionTwoAddress({
    this.addressName,
    required this.id,
    required this.email,
    required this.password,
    required this.archived,
    required this.createdAt,
  });

  factory _ExportVersionTwoAddress.fromJson(Map<String, dynamic> json) {
    return _ExportVersionTwoAddress(
      addressName: json['addressName'],
      id: json['id'],
      email: json['email'],
      password: json['password'],
      archived: json['archived'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'addressName': addressName,
    'id': id,
    'email': email,
    'password': password,
    'archived': archived,
    'createdAt': createdAt,
  };

  // Computed field: fallback to current Date if invalid
  DateTime get createdAtDate {
    try {
      return DateTime.parse(createdAt);
    } catch (_) {
      return DateTime.now();
    }
  }

  // ifNameElseAddress logic
  String get ifNameElseAddress {
    return (addressName != null && addressName!.isNotEmpty) ? addressName! : email;
  }

  // ifNameThenAddress logic
  String get ifNameThenAddress {
    return (addressName != null && addressName!.isNotEmpty) ? email : '';
  }

  Future<AddressData?> toAddressData() async {
    AuthenticatedUser? user = await HttpService.login(email, password);
    if (user == null) {
      return null;
    }
    return AddressData(addressName: addressName ?? '', authenticatedUser: user, password: password);
  }
}

class ExportImportAddress {
  static Future<bool?> exportAddreses(List<AddressData> addresses) async {
    try {
      SaveFileResp saveFileResp = await FSService.saveStringToFile(
        CryptoService.textToBase64(json.encode(_ExportVersionOne(exportDate: DateTime.now(), addresses: addresses).toJson())),
        'TempBoxExport-${UiService.dateToUIString(DateTime.now())}.txt',
      );
      return saveFileResp.status;
    } catch (e) {
      return null;
    }
  }

  static Future<bool?> prepareAddresesForMajorUpdate(List<AddressData> addresses) async {
    try {
      SaveFileResp saveFileResp = await FSService.saveStringToFileInSupportDir(
        CryptoService.textToBase64(json.encode(_ExportVersionOne(exportDate: DateTime.now(), addresses: addresses).toJson())),
        'TempBoxExportMAJOR.txt',
      );
      return saveFileResp.status;
    } catch (e) {
      return null;
    }
  }

  static Future<List<AddressData>?> importAddreses() async {
    try {
      PickFileResp pickFileResp = await FSService.pickFile();
      if (!pickFileResp.status) {
        return null;
      }
      ReadFileResp readFileResp = await FSService.readFileContents(pickFileResp.file);
      if (!readFileResp.status) {
        return null;
      }
      Map<String, dynamic> decodedData = json.decode(CryptoService.validateandToText(readFileResp.contents));
      final versionData = _VersionContainer.fromJson(decodedData);

      if (versionData.version == _ExportVersionOne.version) {
        return _ExportVersionOne.fromJson(decodedData).addresses;
      } else if (versionData.version == _ExportVersionTwo.version) {
        final List<_ExportVersionTwoAddress> addresses = _ExportVersionTwo.fromJson(decodedData).addresses;
        final List<AddressData> loggedInAddresses = [];

        for (var address in addresses) {
          final AddressData? addressData = await address.toAddressData();
          if (addressData != null) {
            loggedInAddresses.add(addressData);
          }
        }

        return loggedInAddresses;
      } else {
        return [];
      }
    } catch (e) {
      return null;
    }
  }
}
