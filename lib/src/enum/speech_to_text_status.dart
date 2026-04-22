/// Represents the status of a speech-to-text conversion process.
enum SpeechToTextStatus {
  /// The voice message has not been converted to text yet.
  notConverted,

  /// The voice message is currently being converted to text.
  converting,

  /// The speech-to-text conversion completed successfully.
  success,

  /// The speech-to-text conversion failed.
  failed,
}
