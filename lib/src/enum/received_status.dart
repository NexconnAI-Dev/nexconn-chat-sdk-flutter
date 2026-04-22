/// Represents the status of a received message on the recipient side.
enum ReceivedStatus {
  /// The message has not been read.
  unread,

  /// The message has been read.
  read,

  /// The voice message has been listened to.
  listened,

  /// The message media content has been downloaded.
  downloaded,

  /// The message content has been retrieved from the server.
  retrieved,

  /// The message was received on multiple devices.
  multipleReceive,
}
