/// Represents the content type of a message in the Nexconn IM SDK.
enum MessageType {
  /// Unknown or unsupported message type.
  unknown,

  /// Custom message defined by the application.
  custom,

  /// Plain text message.
  text,

  /// Voice (audio) message.
  voice,

  /// Image message.
  image,

  /// File attachment message.
  file,

  /// Short video (sight) message.
  sight,

  /// Animated GIF message.
  gif,

  /// Message recall notification.
  recall,

  /// Reference (reply/quote) message that references another message.
  reference,

  /// Command message (not displayed to the user, not persisted).
  command,

  /// Command notification message (displayed but not persisted).
  commandNotification,

  /// Location sharing message.
  location,

  /// User-defined custom message with SDK-level handling.
  userCustom,

  /// Registered custom message created through the SDK custom registration flow.
  customMessage,

  /// Streaming message for real-time content delivery.
  stream,

  /// Registered custom media message with media content.
  customMediaMessage,

  /// Group notification message (e.g., member join/leave events).
  groupNotification,

  /// Combined (merged/forwarded) message containing multiple messages (V2).
  combineV2,
}
