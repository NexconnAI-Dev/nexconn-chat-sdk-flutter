class AppData {
  static const appKey = '';
  static const naviServer = '';

  static const token1 = '';
  static const token2 = '';
  static const token3 = '';

  static String tokenByShortcut(String input) {
    switch (input) {
      case '1':
        return token1;
      case '2':
        return token2;
      case '3':
        return token3;
      default:
        return input;
    }
  }
}
