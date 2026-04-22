/// Defines who has permission to edit a group member's info (e.g., nickname).
enum GroupMemberInfoEditPermission {
  /// The group owner, admins, or the member themselves can edit.
  owneroradminorself,

  /// The group owner or the member themselves can edit.
  ownerorself,

  /// Only the member themselves can edit their own info.
  self,
}
