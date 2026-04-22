/// Represents the current status of a group.
enum GroupStatus {
  /// The group is active and in use.
  using,

  /// The group has been dismissed (disbanded) by the owner.
  dismissed,

  /// The group has been banned by the system administrator.
  banned,

  /// The group is muted; members cannot send messages.
  muted,
}
