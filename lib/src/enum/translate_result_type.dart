/// Defines the type of content returned from a translation operation.
enum TranslateResultType {
  /// The translation result is applied to the message object directly.
  message,

  /// The translation result is returned as a custom text string.
  customText,
}
