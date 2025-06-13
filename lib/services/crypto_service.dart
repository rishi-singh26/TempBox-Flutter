import 'dart:convert';

class CryptoService {
  static String textToBase64(String text) {
    final bytes = utf8.encode(text);
    return base64Encode(bytes);
  }

  static String base64ToText(String base64String) {
    final bytes = base64Decode(base64String);
    return utf8.decode(bytes);
  }

  /// Validate if the input is a valid Base64 String
  static bool isBase64EncodedString(String input) {
    // Step 1: Attempt to decode from Base64
    final String decodedData = base64ToText(input);

    // Step 3: Re-encode the decoded string and compare
    final String reEncoded = textToBase64(decodedData);

    // Step 4: Compare ignoring padding or line wrapping differences
    return reEncoded == input;
  }

  /// Takes String as input.
  /// Checks if the string is Base64 or normal text.
  /// If base64 then converts to normal and returns else returns the input
  static String validateandToText(String input) {
    final bool isBase64 = isBase64EncodedString(input);

    if (isBase64) {
      return base64ToText(input);
    } else {
      return input;
    }
  }
}
