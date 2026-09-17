/// Represents the current state of a message referenced by a reply.
enum ReferenceMessageStatus {
  /// The default state reported by the native SDK.
  ///
  /// This name intentionally mirrors `RCIMIWReferenceMessageStatus.defaultValue`
  /// instead of inventing a second semantic label for the same wire value.
  defaultValue,

  /// The referenced message was modified.
  modified,

  /// The referenced message was recalled.
  recalled,

  /// The referenced message was deleted.
  deleted,
}
