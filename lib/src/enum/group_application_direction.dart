/// Represents the direction of a group join/invite application.
enum GroupApplicationDirection {
  /// The current user sent a join application to the group.
  applicationsent,

  /// The current user sent an invitation to another user.
  invitationsent,

  /// The current user received an invitation to join a group.
  invitationreceived,

  /// The current user (as admin/owner) received a join application.
  applicationreceived,
}
