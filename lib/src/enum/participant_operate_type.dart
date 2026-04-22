/// Represents the type of ban/unban operation on a participant.
enum OpenChannelParticipantBanType {
  /// Unban the participant, restoring their access.
  deblock,

  /// Ban the participant, restricting their access.
  blocked,
}
