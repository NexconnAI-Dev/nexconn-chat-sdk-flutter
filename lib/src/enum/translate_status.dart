/// Represents the status of a translation operation.
enum TranslateStatus {
  /// No translation has been performed.
  none,

  /// The translation is in progress.
  translating,

  /// The translation completed successfully.
  success,

  /// The translation failed.
  failed,
}
