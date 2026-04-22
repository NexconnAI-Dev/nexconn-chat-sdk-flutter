/// Defines the automatic translation strategy for messages.
enum TranslateStrategy {
  /// Follow the user's default translation setting.
  defaultFollowUser,

  /// Automatically translate messages when received.
  autoOn,

  /// Do not automatically translate messages.
  autoOff,
}
