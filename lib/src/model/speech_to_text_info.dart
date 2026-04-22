import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/speech_to_text_status.dart';

/// Represents the result of a speech-to-text conversion.
class SpeechToTextInfo {
  final RCIMIWSpeechToTextInfo _raw;
  SpeechToTextInfo._(this._raw);

  /// Creates a [SpeechToTextInfo] from an existing SDK object.
  static SpeechToTextInfo fromRaw(RCIMIWSpeechToTextInfo raw) =>
      SpeechToTextInfo._(raw);

  /// The status of the speech-to-text conversion (e.g., success, failure).
  SpeechToTextStatus? get status =>
      _raw.status != null
          ? SpeechToTextStatus.values[_raw.status!.index]
          : null;

  /// The transcribed text content from the audio.
  String? get text => _raw.text;

  /// Whether the transcribed text should be visible to the user.
  bool? get visible => _raw.visible;

  /// The associated SDK object for advanced usage.
  RCIMIWSpeechToTextInfo get raw => _raw;
}
