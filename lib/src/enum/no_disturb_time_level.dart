/// Represents the Do Not Disturb level for a specific channel within a time period.
enum NoDisturbTimeLevel {
  /// No Do Not Disturb setting; all notifications are allowed.
  none,

  /// Only receive notifications for messages that mention the user.
  mentionMessage,

  /// Block all notifications from this channel.
  blocked,
}
