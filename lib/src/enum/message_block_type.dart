/// Represents the type of message blocking applied by the server.
enum MessageBlockType {
  /// Unknown block type.
  unknown,

  /// The message was blocked by global content moderation rules.
  global,

  /// The message was blocked by custom content moderation rules.
  custom,

  /// The message was blocked by a third-party content moderation service.
  thirdParty,
}
