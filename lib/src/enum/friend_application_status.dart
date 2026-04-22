/// Represents the current status of a friend request application.
enum FriendApplicationStatus {
  /// The friend request has not been handled yet.
  unhandled,

  /// The friend request has been accepted.
  accepted,

  /// The friend request has been refused.
  refused,

  /// The friend request has expired.
  expired,
}
