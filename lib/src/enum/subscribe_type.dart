/// Represents the type of subscription event for user status monitoring.
enum SubscribeType {
  /// Invalid or unset subscription type.
  invalid,

  /// Subscribe to a user's online/offline status changes.
  onlineStatus,

  /// Subscribe to a user's profile information changes.
  userProfile,

  /// Subscribe to a friend's online/offline status changes.
  friendOnlineStatus,

  /// Subscribe to a friend's profile information changes.
  friendUserProfile,
}
