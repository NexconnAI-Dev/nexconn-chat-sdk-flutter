import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../engine/nc_engine.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import 'message.dart';

/// A streaming message in the Nexconn IM SDK.
///
/// Used for AI/LLM streaming scenarios where content is delivered incrementally.
/// Each stream message represents a chunk of the overall content, with flags indicating completion and synchronization state.
class StreamMessage extends Message {
  /// Creates a [StreamMessage] by wrapping a raw message object.
  StreamMessage.wrap(super.raw) : super.wrap();

  /// Creates a [StreamMessage] from an existing SDK object.
  static StreamMessage fromRaw(RCIMIWStreamMessage raw) =>
      StreamMessage.wrap(raw);

  RCIMIWStreamMessage get _streamRaw => raw as RCIMIWStreamMessage;

  /// The text content of this stream chunk.
  String? get content => _streamRaw.content;

  /// The content type identifier for the stream data.
  String? get type => _streamRaw.type;

  /// Whether the stream has completed (all chunks have been delivered).
  bool? get complete => _streamRaw.complete;

  /// Whether this stream chunk is a synchronized (historical) message rather than a real-time delivery.
  bool? get sync => _streamRaw.sync;

  /// The reason code for stream completion (e.g., normal finish, error).
  int? get completeReason => _streamRaw.completeReason;

  /// The reason code if the stream was stopped prematurely.
  int? get stopReason => _streamRaw.stopReason;

  /// Requests the stream message content from the server.
  ///
  /// After calling this method, the stream data will be delivered through [MessageHandler.onStreamMessageRequestInit], [MessageHandler.onStreamMessageRequestData], and [MessageHandler.onStreamMessageRequestComplete] callbacks.
  ///
  /// [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> requestStreamMessage(ErrorHandler handler) {
    final params = RCIMIWStreamMessageRequestParams.create(
      messageUId: messageId,
    );
    return NCEngine.engine.requestStreamMessageContent(
      params,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  @override
  Map<String, dynamic> extraJson() => {
    'content': content,
    'type': type,
    'complete': complete,
    'sync': sync,
    'completeReason': completeReason,
    'stopReason': stopReason,
  };
}
