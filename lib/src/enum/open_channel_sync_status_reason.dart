/// Represents the reason for an open channel sync status change.
enum OpenChannelSyncStatusReason {
  /// The user left the open channel on their own.
  leaveonmyown,

  /// The user was disconnected because another device logged in.
  otherdevicelogin,
}
