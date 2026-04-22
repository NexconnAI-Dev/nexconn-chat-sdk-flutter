/// Represents the current status of a group join/invite application.
enum GroupApplicationStatus {
  /// The application is pending review by the group admin/owner.
  adminunhandled,

  /// The application has been refused by the group admin/owner.
  adminrefused,

  /// The invitation is pending acceptance by the invitee.
  inviteeunhandled,

  /// The invitation has been refused by the invitee.
  inviteerefused,

  /// The user has successfully joined the group.
  joined,

  /// The application or invitation has expired.
  expired,
}
