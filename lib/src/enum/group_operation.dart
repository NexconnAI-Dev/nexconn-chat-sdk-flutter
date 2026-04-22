/// Represents a high-level group membership or ownership operation.
enum GroupOperation {
  /// A group was created.
  create,

  /// A user joined a group.
  join,

  /// A member was removed from a group.
  kick,

  /// A user quit a group.
  quit,

  /// A group was dismissed.
  dismiss,

  /// A group admin was added.
  addAdmin,

  /// A group admin was removed.
  removeAdmin,

  /// Group ownership was transferred.
  transferGroupOwner,
}
