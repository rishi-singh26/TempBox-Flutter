import 'dart:math';

class IdService {
  static String generateUUIDv4() {
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Adjust certain bits according to RFC 4122 section 4.4 as described below:
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // Set the 4 most significant bits of the 7th byte to 0100 (UUID version 4)
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // Set the 2 most significant bits of the 9th byte to 10

    return bytesToUuid(bytes);
  }

  static String bytesToUuid(List<int> bytes) {
    final List<String> chars = List<String>.filled(36, '');
    final List<String> hexDigits = '0123456789abcdef'.split('');

    for (int i = 0, j = 0; i < 16; i++) {
      final int byte = bytes[i];
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        chars[j++] = '-';
      }
      chars[j++] = hexDigits[byte >> 4];
      chars[j++] = hexDigits[byte & 0x0F];
    }

    return chars.join('');
  }
}
