import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';

class UiService {
  static List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static getAccountName(AddressData addressData) {
    return addressData.addressName.isNotEmpty ? addressData.addressName : addressData.authenticatedUser.account.address.split('@').first;
  }

  static getMessageFromName(Message message) {
    if (message.from['name']!.isEmpty) {
      return message.from['address'] ?? '';
    } else {
      return message.from['name'] ?? '';
    }
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
}
