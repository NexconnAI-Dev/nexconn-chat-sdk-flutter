/// Defines the visibility setting for a user's profile information.
enum UserProfileVisibility {
  /// No visibility preference has been set.
  notSet,

  /// The user's profile is invisible to others.
  invisible,

  /// The user's profile is visible to everyone.
  everyone,

  /// The user's profile is visible only to friends.
  friendVisible,
}
