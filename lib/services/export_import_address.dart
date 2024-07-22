import 'dart:convert';

import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/crypto_service.dart';
import 'package:tempbox/services/fs_service.dart';
import 'package:tempbox/services/ui_service.dart';

class _ExportVersionOne {
  final String version = '1.0.0';
  final DateTime exportDate;
  final List<AddressData> addresses;

  _ExportVersionOne({required this.exportDate, required this.addresses});

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }

  factory _ExportVersionOne.fromJson(Map<String, dynamic> json) {
    return _ExportVersionOne(
      exportDate: DateTime.parse(json['exportDate']),
      addresses: (json['addresses'] as List).map((address) => AddressData.fromJson(address)).toList(),
    );
  }
}

class ExportImportAddress {
  static Future<bool?> exportAddreses(List<AddressData> addresses) async {
    try {
      await FSService.saveStringToFile(
        CryptoService.textToBase64(json.encode(_ExportVersionOne(exportDate: DateTime.now(), addresses: addresses).toJson())),
        'TempBoxExport-${UiService.dateToUIString(DateTime.now())}.txt',
      );
      return true;
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
      if (!pickFileResp.status) {
        return null;
      }
      return _ExportVersionOne.fromJson(json.decode(CryptoService.base64ToText(readFileResp.contents))).addresses;
    } catch (e) {
      return null;
    }
  }
}
