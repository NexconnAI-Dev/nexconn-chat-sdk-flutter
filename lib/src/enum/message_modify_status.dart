/// Represents the state of a message modification.
enum MessageModifyStatus {
  /// The message was modified successfully.
  success,

  /// The message modification is still in progress.
  updating,

  /// The message modification failed.
  failed,
}
