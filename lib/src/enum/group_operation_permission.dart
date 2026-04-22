/// Defines who has permission to perform group operations (e.g., modify group info).
enum GroupOperationPermission {
  /// Only the group owner has permission.
  owner,

  /// The group owner or admins have permission.
  owneroradmin,

  /// All group members have permission.
  everyone,
}
