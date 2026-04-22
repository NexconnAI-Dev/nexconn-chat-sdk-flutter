/// Represents the role of a member within a group.
enum GroupMemberRole {
  /// Undefined or unset role.
  undef,

  /// Regular group member with basic permissions.
  normal,

  /// Group admin with elevated permissions.
  admin,

  /// Group owner with full control over the group.
  owner,
}
