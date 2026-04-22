/// Defines the persistence and counting behavior for registered custom messages.
enum CustomMessagePersistentFlag {
  /// The message is not persisted and not counted in unread.
  none,

  /// The message is persisted locally and on the server.
  persisted,

  /// The message is persisted and counted in the unread message count.
  counted,

  /// The message is treated as a status message (not persisted, not counted).
  status,
}
