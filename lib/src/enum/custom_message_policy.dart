/// Defines the storage and notification policy for custom messages.
enum CustomMessagePolicy {
  /// Command message: not persisted, not counted in unread, not pushed offline.
  command,

  /// Normal message: persisted, counted in unread, pushed when offline.
  normal,

  /// Status message: not persisted, not counted in unread, used for real-time status updates.
  status,

  /// Storage message: persisted on the server but not counted in unread.
  storage,
}
