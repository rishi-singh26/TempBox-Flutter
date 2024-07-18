enum SizeUnit { tb, gb, mb, kb, b }

class ByteConverterService {
  double bytes = 0.0;
  int bits = 0;

  ByteConverterService.fromBytes(this.bytes) {
    bits = (bytes * 8).ceil();
  }

  ByteConverterService.fromBits(this.bits) {
    bytes = bits / 8;
  }

  double _withPrecision(double value, [int precision = 2]) {
    return double.parse(value.toStringAsFixed(precision));
  }

  double get kiloBytes => bytes / 1000;
  double get megaBytes => bytes / 1000000;
  double get gigaBytes => bytes / 1000000000;
  double get teraBytes => bytes / 1000000000000;
  double get petaBytes => bytes / 1E+15;

  double asBytes([int precision = 2]) {
    return _withPrecision(bytes, precision);
  }

  static ByteConverterService fromKibiBytes(double value) {
    return ByteConverterService.fromBytes(value * 1024);
  }

  static ByteConverterService fromMebiBytes(double value) {
    return ByteConverterService.fromBytes(value * 1048576);
  }

  static ByteConverterService fromGibiBytes(double value) {
    return ByteConverterService.fromBytes(value * 1073741824);
  }

  static ByteConverterService fromTebiBytes(double value) {
    return ByteConverterService.fromBytes(value * 1099511627776);
  }

  static ByteConverterService fromPebiBytes(double value) {
    return ByteConverterService.fromBytes(value * 1125899906842624);
  }

  static ByteConverterService fromKiloBytes(double value) {
    return ByteConverterService.fromBytes(value * 1000);
  }

  static ByteConverterService fromMegaBytes(double value) {
    return ByteConverterService.fromBytes(value * 1000000);
  }

  static ByteConverterService fromGigaBytes(double value) {
    return ByteConverterService.fromBytes(value * 1000000000);
  }

  static ByteConverterService fromTeraBytes(double value) {
    return ByteConverterService.fromBytes(value * 1000000000000);
  }

  static ByteConverterService fromPetaBytes(double value) {
    return ByteConverterService.fromBytes(value * 1E+15);
  }

  ByteConverterService add(ByteConverterService other) {
    return ByteConverterService.fromBytes(bytes + other.bytes);
  }

  ByteConverterService subtract(ByteConverterService other) {
    return ByteConverterService.fromBytes(bytes - other.bytes);
  }

  static bool greaterThan(ByteConverterService left, ByteConverterService right) {
    return left.bits > right.bits;
  }

  static bool lessThan(ByteConverterService left, ByteConverterService right) {
    return left.bits < right.bits;
  }

  static bool lessThanOrEqual(ByteConverterService left, ByteConverterService right) {
    return left.bits <= right.bits;
  }

  static bool greaterThanOrEqual(ByteConverterService left, ByteConverterService right) {
    return left.bits >= right.bits;
  }

  static int compare(ByteConverterService left, ByteConverterService right) {
    if (left.bits < right.bits) return -1;
    if (left.bits == right.bits) return 0;
    return 1;
  }

  int compareTo(ByteConverterService other) {
    if (bits < other.bits) return -1;
    if (bits == other.bits) return 0;
    return 1;
  }

  bool isEqual(ByteConverterService other) {
    return bits == other.bits;
  }

  String toHumanReadable(SizeUnit unit, [int precision = 2]) {
    switch (unit) {
      case SizeUnit.tb:
        return '${_withPrecision(teraBytes, precision)} TB';
      case SizeUnit.gb:
        return '${_withPrecision(gigaBytes, precision)} GB';
      case SizeUnit.mb:
        return '${_withPrecision(megaBytes, precision)} MB';
      case SizeUnit.kb:
        return '${_withPrecision(kiloBytes, precision)} KB';
      case SizeUnit.b:
        return '${asBytes(precision)} B';
    }
  }
}
