/// Represents the status of an open channel.
enum OpenChannelStatus {
  /// The open channel has been reset.
  reset,

  /// The open channel was manually destroyed by an administrator.
  destroyManual,

  /// The open channel was automatically destroyed due to inactivity.
  destroyAuto,
}
