import 'package:ai_nexconn_chat_plugin/src/engine/nc_engine.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import 'message.dart';

/// Handler for tracking media message download progress and completion.
class DownloadMediaMessageHandler {
  /// Called periodically during download with the current progress percentage.
  final void Function(MediaMessage? message, int? progress)? onProgress;

  /// Called when the download is canceled.
  final void Function(MediaMessage? message)? onCanceled;

  /// Called when the download completes, with a status code and the downloaded message.
  final void Function(int? code, MediaMessage? message) onComplete;

  /// Creates a [DownloadMediaMessageHandler].
  ///
  /// [onComplete] is required and called when download finishes.
  /// [onProgress] and [onCanceled] are optional callbacks.
  DownloadMediaMessageHandler({
    this.onProgress,
    this.onCanceled,
    required this.onComplete,
  });
}

/// A message that contains media content (e.g., image, voice, video, file).
///
/// Extends [Message] with local/remote file paths and media download capabilities.
/// Serves as the base class for [ImageMessage], [HDVoiceMessage], [ShortVideoMessage], [FileMessage], [GIFMessage], and other media-type messages.
class MediaMessage extends Message {
  /// Creates a [MediaMessage] by wrapping a raw message object.
  MediaMessage.wrap(super.raw) : super.wrap();

  /// Creates a [MediaMessage] from an existing SDK object.
  static MediaMessage fromRaw(RCIMIWMediaMessage raw) => MediaMessage.wrap(raw);

  RCIMIWMediaMessage get _mediaRaw => raw as RCIMIWMediaMessage;

  /// The local file path of the media content on the device.
  String? get localPath => _mediaRaw.local;

  /// Sets the local file path of the media content.
  set localPath(String? v) => _mediaRaw.local = v;

  /// The remote URL of the media content on the server.
  String? get remotePath => _mediaRaw.remote;

  /// Downloads the media content from the server.
  ///
  /// [handler] provides optional callbacks for progress, cancellation, and completion.
  /// Returns a status code indicating whether the download request was accepted.
  Future<int> downloadMedia({DownloadMediaMessageHandler? handler}) {
    RCIMIWDownloadMediaMessageListener? rawListener;
    if (handler != null) {
      rawListener = RCIMIWDownloadMediaMessageListener(
        onMediaMessageDownloading:
            handler.onProgress != null
                ? (msg, progress) => handler.onProgress!(
                  msg != null
                      ? Converter.fromRawMessage(msg) as MediaMessage
                      : null,
                  progress,
                )
                : null,
        onDownloadingMediaMessageCanceled:
            handler.onCanceled != null
                ? (msg) => handler.onCanceled!(
                  msg != null
                      ? Converter.fromRawMessage(msg) as MediaMessage
                      : null,
                )
                : null,
        onMediaMessageDownloaded:
            (code, msg) => handler.onComplete(
              code,
              msg != null
                  ? Converter.fromRawMessage(msg) as MediaMessage
                  : null,
            ),
      );
    }
    return NCEngine.engine.downloadMediaMessage(
      _mediaRaw,
      listener: rawListener,
    );
  }

  /// Cancels an ongoing media download for this message.
  ///
  /// [handler] is called with the message and error result upon cancellation.
  Future<int> cancelDownloadingMedia(OperationHandler<MediaMessage> handler) {
    return NCEngine.engine.cancelDownloadingMediaMessage(
      _mediaRaw,
      callback: IRCIMIWCancelDownloadingMediaMessageCallback(
        onCancelDownloadingMediaMessageCalled:
            (code, msg) => handler(
              msg != null
                  ? Converter.fromRawMessage(msg) as MediaMessage
                  : null,
              Converter.toNCError(code),
            ),
      ),
    );
  }

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'localPath': localPath,
    'remotePath': remotePath,
  };
}
