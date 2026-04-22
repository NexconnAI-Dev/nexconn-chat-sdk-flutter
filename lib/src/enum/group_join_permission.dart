/// Defines who can verify and approve group join requests.
enum GroupJoinPermission {
  /// Only the group owner can verify and approve join requests.
  ownerverify,

  /// Anyone can freely join the group without approval.
  free,

  /// The group owner or admins can verify and approve join requests.
  owneroradminverify,

  /// No one is allowed to join the group.
  nooneallowed,
}
