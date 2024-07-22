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
}
