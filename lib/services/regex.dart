class RegxService {
  /// Validates the PAN Number "PAN has 10 characters, first five are alphabets, next four are digits and at last an alphabet"
  static bool validatePAN(String pan) {
    String pattern = r"^[A-Z]{5}[0-9]{4}[A-Z]{1}$";
    return RegExp(pattern).hasMatch(pan);
  }

  /// Validates Aadhar number ie 12 digits no alphabets
  static bool validateAadhar(String string) {
    String pattern = r"^[0-9]{12}$";
    return RegExp(pattern).hasMatch(string);
  }

  /// Validates Phone number ie 10 digits no alphabets
  static bool validatePhoneNum(String string) {
    String pattern = r"^[0-9]{10}$";
    return RegExp(pattern).hasMatch(string);
  }

  /// Validates Panjikaran number ie 13 digits no alphabets
  static bool validatePanjikaranNum(String string) {
    String pattern = r"^[0-9]{13}$";
    return RegExp(pattern).hasMatch(string);
  }

  /// validated the email
  static bool validateEmail(String email) {
    String pattern =
        r"^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$";
    return RegExp(pattern).hasMatch(email);
  }

  /// checks if the string is pure ie. only alphabets in UPPERCASE and lowercase and spaces
  static bool validatePureString(String string) {
    String pattern = r"^[a-z,A-Z, ]+$";
    return RegExp(pattern).hasMatch(string);
  }

  /// checks if the string is a number ie. only digits from 0-9
  static bool validateStringIsNumber(String string) {
    String pattern = r"^[0-9]+$";
    return RegExp(pattern).hasMatch(string);
  }

  static bool validateURL(String url) {
    String pattern =
        r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$";
    return RegExp(pattern).hasMatch(url);
  }
}
