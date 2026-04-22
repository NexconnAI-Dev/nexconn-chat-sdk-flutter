/// Represents the sending status of a message.
enum SentStatus {
  /// The message is currently being sent.
  sending,

  /// The message failed to send.
  failed,

  /// The message has been sent to the server.
  sent,

  /// The message has been received by the recipient.
  received,

  /// The message has been read by the recipient.
  read,

  /// The message has been destroyed (e.g., burn after reading).
  destroyed,

  /// The message sending has been canceled.
  canceled,
}
