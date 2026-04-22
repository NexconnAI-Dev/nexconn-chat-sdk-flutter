/// Represents the friend relationship status between two users.
enum FriendRelationType {
  /// No friend relationship exists.
  none,

  /// The target user is in the current user's friend list.
  inMyFriendList,

  /// The current user is in the target user's friend list.
  inOtherFriendList,

  /// Both users are in each other's friend lists (mutual friends).
  inBothFriendList,
}
