/// Represents the Do Not Disturb (push notification) level for a channel.
enum ChannelNoDisturbLevel {
  /// Receive push notifications for all messages.
  allMessage,

  /// No Do Not Disturb setting applied (default behavior).
  none,

  /// Only receive push notifications for mentioned messages (both @all and @specific users).
  mention,

  /// Only receive push notifications when specifically mentioned (@user).
  mentionUsers,

  /// Only receive push notifications for @all mentions.
  mentionAll,

  /// Block all push notifications from this channel.
  blocked,
}
