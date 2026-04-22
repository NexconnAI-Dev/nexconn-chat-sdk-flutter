/// Represents the type of mute operation on participants in an open channel.
enum OpenChannelParticipantMuteType {
  /// Unmute specific users, restoring their ability to send messages.
  unmuteUsers,

  /// Mute specific users, preventing them from sending messages.
  muteUsers,

  /// Unmute all participants in the channel.
  unmuteAll,

  /// Mute all participants in the channel.
  muteAll,

  /// Remove specific users from the allowlist.
  removeAllowlist,

  /// Add specific users to the allowlist (can speak when channel is muted).
  addAllowlist,

  /// Remove the global mute restriction on a user across all channels.
  unmuteGlobal,

  /// Apply a global mute restriction on a user across all channels.
  muteGlobal,
}
