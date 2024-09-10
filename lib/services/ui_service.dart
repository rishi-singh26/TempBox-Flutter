import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';

class UiService {
  static List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String getAccountName(AddressData addressData, {bool shortName = false}) {
    if (addressData.addressName.isNotEmpty) {
      final bool shouldShorten = addressData.addressName.length > 15 && shortName;
      return '${addressData.addressName.substring(0, shouldShorten ? 15 : addressData.addressName.length)}${shouldShorten ? "..." : ""}';
    } else {
      return addressData.authenticatedUser.account.address.split('@').first;
    }
  }

  static String getMessageFromName(MessageData message) {
    if (message.from['name']!.isEmpty) {
      return message.from['address'] ?? '';
    } else {
      return message.from['name'] ?? '';
    }
  }

  static String getInboxSubtitleFromMessages(List<MessageData> messages) {
    Iterable<MessageData> unreadMessages = messages.where((m) => !m.seen);
    String messageSuffix = messages.length > 1 ? 's' : '';
    if (unreadMessages.isEmpty) {
      return '${messages.length} Message$messageSuffix';
    }
    return '${messages.length} Message$messageSuffix, ${unreadMessages.length} unread';
  }

  static copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static String dateToUIString(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = monthNames[dateTime.month - 1];
    String year = dateTime.year.toString();
    return '$day $month $year';
  }

  static String formatTimeTo12Hour(DateTime dateTime) {
    // Get the hour, minute, and period (AM/PM)
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert hour to 12-hour format
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Handle the midnight and noon cases

    // Format the minute to always have two digits
    String minuteStr = minute.toString().padLeft(2, '0');

    // Return the formatted time string
    return '$hour:$minuteStr $period';
  }

  static String generateRandomString(int length, {bool useUpperCase = false, bool useNumbers = false, bool useSpecialCharacters = false}) {
    String characters = 'abcdefghijklmnopqrstuvwxyz';
    if (useUpperCase) {
      characters += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (useNumbers) {
      characters += '0123456789';
    }
    if (useSpecialCharacters) {
      characters += "@\$%&*#()";
    }
    final random = Random();
    return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
  }

  static String getStatusText(AddressData addressData) {
    if (addressData.authenticatedUser.account.isDeleted) {
      return 'Deleted';
    } else if (addressData.authenticatedUser.account.isDisabled) {
      return 'Disabled';
    } else {
      return 'Active';
    }
  }

  static Color getStatusColor(AddressData addressData, [bool useCupertinoColor = true]) {
    if (useCupertinoColor) {
      if (addressData.authenticatedUser.account.isDeleted) {
        return CupertinoColors.systemRed;
      } else if (addressData.authenticatedUser.account.isDisabled) {
        return CupertinoColors.systemYellow;
      } else {
        return CupertinoColors.systemGreen;
      }
    } else {
      if (addressData.authenticatedUser.account.isDeleted) {
        return Colors.red;
      } else if (addressData.authenticatedUser.account.isDisabled) {
        return Colors.yellow;
      } else {
        return Colors.green;
      }
    }
  }

  static String getQuotaString(int bytes, SizeUnit unit) {
    return ByteConverterService.fromBytes(bytes.toDouble()).toHumanReadable(unit);
  }
}
