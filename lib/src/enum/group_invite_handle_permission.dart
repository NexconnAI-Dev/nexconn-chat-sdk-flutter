/// Defines how group invitations are handled.
enum GroupInviteHandlePermission {
  /// Invitees join the group directly without needing to confirm.
  free,

  /// Invitees must confirm before joining the group.
  inviteeverify,
}
