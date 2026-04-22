import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../engine/nc_engine.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [HDVoiceMessage].
class HDVoiceMessageParams extends MessageParams {
  /// The local file path of the HD voice recording.
  final String path;

  /// The duration of the HD voice recording in seconds.
  final int duration;

  /// Creates [HDVoiceMessageParams] with the required audio [path] and [duration].
  HDVoiceMessageParams({
    required this.path,
    required this.duration,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A HD voice (audio) message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] with HD voice-specific properties and capabilities
/// such as duration and speech-to-text conversion.
class HDVoiceMessage extends MediaMessage {
  /// Creates a [HDVoiceMessage] by wrapping a raw message object.
  HDVoiceMessage.wrap(super.raw) : super.wrap();

  /// Creates a [HDVoiceMessage] from an existing SDK object.
  static HDVoiceMessage fromRaw(RCIMIWVoiceMessage raw) =>
      HDVoiceMessage.wrap(raw);

  RCIMIWVoiceMessage get _voiceRaw => raw as RCIMIWVoiceMessage;

  /// The duration of the HD voice message in seconds.
  int? get duration => _voiceRaw.duration;

  /// Sets the duration of the HD voice message in seconds.
  set duration(int? v) => _voiceRaw.duration = v;

  /// Requests speech-to-text conversion for this HD voice message.
  ///
  /// [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> requestSpeechToText(ErrorHandler handler) {
    return NCEngine.engine.requestSpeechToTextForMessage(
      messageId!,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the visibility of the speech-to-text result for this HD voice message.
  ///
  /// [visible] controls whether the transcription text is shown.
  /// [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> setSpeechToTextVisible(bool visible, ErrorHandler handler) {
    return NCEngine.engine.setMessageSpeechToTextVisible(
      clientId!,
      visible,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'duration': duration,
  };
}
