/// Defines the scope of a message operation (e.g., delete, clear).
enum MessageOperationPolicy {
  /// Operate on local messages only.
  local,

  /// Operate on remote (server-side) messages only.
  remote,

  /// Operate on both local and remote messages.
  localRemote,
}
