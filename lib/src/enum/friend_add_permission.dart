/// Defines the policy for handling incoming friend requests.
enum FriendAddPermission {
  /// No friend request policy has been set.
  ///
  /// This value is returned by query APIs as a placeholder and must not be
  /// passed to `setFriendAddPermission`.
  notSet,

  /// Accept all friend requests automatically.
  free,

  /// Friend requests require manual verification and approval.
  needVerify,

  /// Reject all friend requests; no one can send friend requests.
  noOneAllowed,
}
